-- CreateEnum
CREATE TYPE "UserRoles" AS ENUM ('OWNER', 'ADMIN', 'USER', 'SAC', 'GUEST');

-- CreateEnum
CREATE TYPE "EntityType" AS ENUM ('USER', 'UserToken', 'Provider', 'StripeSubscription');

-- CreateEnum
CREATE TYPE "ProviderType" AS ENUM ('GOOGLE', 'APPLE', 'LOCAL', 'X');

-- CreateEnum
CREATE TYPE "PaymentType" AS ENUM ('PIX', 'CASH', 'CARD');

-- CreateTable
CREATE TABLE "users_tokens" (
    "id" SERIAL NOT NULL,
    "token" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" SERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "token" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT,
    "document" VARCHAR(14),
    "phones" TEXT[],
    "status" BOOLEAN NOT NULL DEFAULT false,
    "password" TEXT,
    "avatar" TEXT,
    "roles" "UserRoles"[] DEFAULT ARRAY['USER']::"UserRoles"[],
    "birth_date" DATE NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,
    "lgpd_excluded_at" DATE,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "providers" (
    "id" SERIAL NOT NULL,
    "provider" "ProviderType" NOT NULL,
    "provider_id" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "providers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stripe_subscription" (
    "id" SERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "customer_id" TEXT NOT NULL,
    "subscription_id" TEXT NOT NULL,
    "subscription_status" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,
    "lgpd_excluded_at" DATE,

    CONSTRAINT "stripe_subscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users_address" (
    "id" SERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "address" TEXT NOT NULL,
    "cep" TEXT NOT NULL,
    "complement" TEXT,
    "neighborhood" TEXT NOT NULL,
    "number" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_address_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "sessions_token_key" ON "sessions"("token");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_document_key" ON "users"("document");

-- CreateIndex
CREATE UNIQUE INDEX "providers_user_id_key" ON "providers"("user_id");

-- CreateIndex
CREATE INDEX "providers_provider_idx" ON "providers"("provider");

-- CreateIndex
CREATE UNIQUE INDEX "providers_provider_provider_id_key" ON "providers"("provider", "provider_id");

-- CreateIndex
CREATE UNIQUE INDEX "stripe_subscription_user_id_key" ON "stripe_subscription"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "stripe_subscription_customer_id_key" ON "stripe_subscription"("customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "stripe_subscription_subscription_id_key" ON "stripe_subscription"("subscription_id");

-- CreateIndex
CREATE INDEX "stripe_subscription_subscription_status_idx" ON "stripe_subscription"("subscription_status");

-- AddForeignKey
ALTER TABLE "users_tokens" ADD CONSTRAINT "users_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "providers" ADD CONSTRAINT "providers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stripe_subscription" ADD CONSTRAINT "stripe_subscription_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users_address" ADD CONSTRAINT "users_address_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
