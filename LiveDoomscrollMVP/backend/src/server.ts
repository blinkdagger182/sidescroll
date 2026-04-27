import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";
import Fastify from "fastify";
import { AccessToken } from "livekit-server-sdk";
import { nanoid } from "nanoid";
import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z.string().default("development"),
  PORT: z.coerce.number().int().positive().default(3000),
  CORS_ORIGIN: z.string().default("*"),
  LIVEKIT_URL: z.string().url(),
  LIVEKIT_API_KEY: z.string().min(1),
  LIVEKIT_API_SECRET: z.string().min(1),
  TOKEN_TTL_SECONDS: z.coerce.number().int().positive().default(60 * 60 * 2),
  ROOM_PREFIX: z.string().default("doomscroll"),
});

const env = envSchema.parse(process.env);
const serviceVersion = process.env.npm_package_version ?? "0.1.0";

const tokenRequestSchema = z.object({
  roomName: z
    .string()
    .trim()
    .min(1)
    .max(80)
    .regex(/^[a-zA-Z0-9_-]+$/),
  participantName: z.string().trim().min(1).max(80).optional(),
});

const app = Fastify({
  logger: true,
});

await app.register(cors, {
  origin: env.CORS_ORIGIN === "*" ? true : env.CORS_ORIGIN.split(","),
});

await app.register(rateLimit, {
  max: 60,
  timeWindow: "1 minute",
});

app.get("/health", async () => ({
  ok: true,
  service: "sidescroll-livekit-token-backend",
  version: serviceVersion,
}));

app.get("/v1/livekit/config", async () => ({
  liveKitUrl: env.LIVEKIT_URL,
  roomPrefix: env.ROOM_PREFIX,
}));

app.post("/v1/livekit/token", async (request, reply) => {
  const parsed = tokenRequestSchema.safeParse(request.body);
  if (!parsed.success) {
    return reply.code(400).send({
      error: "invalid_request",
      details: parsed.error.flatten(),
    });
  }

  const roomName = `${env.ROOM_PREFIX}-${parsed.data.roomName}`;
  const identity = `ios-${nanoid(12)}`;
  const displayName = parsed.data.participantName ?? "iPhone";

  // Backend TODO: before minting a token, enforce private-room membership,
  // invite links, matchmaking, blocks, moderation/reporting state, and abuse limits.
  const accessToken = new AccessToken(env.LIVEKIT_API_KEY, env.LIVEKIT_API_SECRET, {
    identity,
    name: displayName,
    ttl: env.TOKEN_TTL_SECONDS,
  });

  accessToken.addGrant({
    room: roomName,
    roomJoin: true,
    canPublish: true,
    canSubscribe: true,
    canPublishData: true,
  });

  return {
    liveKitUrl: env.LIVEKIT_URL,
    token: await accessToken.toJwt(),
    roomName,
    identity,
  };
});

try {
  await app.listen({ host: "0.0.0.0", port: env.PORT });
} catch (error) {
  app.log.error(error);
  process.exit(1);
}
