-- CreateEnum
CREATE TYPE "UserRoles" AS ENUM ('OWNER', 'ADMIN', 'USER', 'ASSISTANT', 'SELLER', 'SUPERVISOR', 'DIRECTOR', 'FINANCIAL', 'HR', 'SAC', 'GUEST');

-- CreateEnum
CREATE TYPE "UserSectors" AS ENUM ('MANAGER', 'DIRECTOR', 'ASSISTANT', 'IT', 'MARKETING', 'SALES', 'BILLING', 'FINANCE', 'HR', 'SAC', 'GUEST');

-- CreateEnum
CREATE TYPE "CustomerType" AS ENUM ('CPF', 'CNPJ');

-- CreateEnum
CREATE TYPE "EntityType" AS ENUM ('USER', 'STORE', 'CUSTOMER', 'ORDER', 'SERVICE', 'SUB_SERVICE');

-- CreateEnum
CREATE TYPE "EntityMediaType" AS ENUM ('ORDER', 'SERVICE', 'SUB_SERVICE');

-- CreateEnum
CREATE TYPE "PaymentType" AS ENUM ('PIX', 'CASH', 'CARD');

-- CreateTable
CREATE TABLE "users_tokens" (
    "id" UUID NOT NULL,
    "token" UUID NOT NULL,
    "user_id" UUID NOT NULL,

    CONSTRAINT "users_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "document" VARCHAR(14) NOT NULL,
    "status" BOOLEAN NOT NULL DEFAULT false,
    "password" VARCHAR(100) NOT NULL,
    "avatar" TEXT,
    "roles" "UserRoles"[] DEFAULT ARRAY['USER']::"UserRoles"[],
    "sectors" "UserSectors"[] DEFAULT ARRAY['MANAGER']::"UserSectors"[],
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,
    "lgpd_excluded_at" DATE,
    "store_id" UUID,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stores" (
    "id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "slogan" VARCHAR(255),
    "document" VARCHAR(18) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "instagram" VARCHAR(255),
    "address" VARCHAR(255) NOT NULL,
    "cep" VARCHAR(255) NOT NULL,
    "complement" VARCHAR(255),
    "neighborhood" VARCHAR(255) NOT NULL,
    "number" VARCHAR(255) NOT NULL,
    "city" VARCHAR(255) NOT NULL,
    "state" VARCHAR(255) NOT NULL,
    "logo" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,
    "lgpd_excluded_at" DATE,

    CONSTRAINT "stores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stripe_subscription" (
    "id" SERIAL NOT NULL,
    "store_id" UUID NOT NULL,
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
CREATE TABLE "services" (
    "id" UUID NOT NULL,
    "store_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "value_fixed" BOOLEAN NOT NULL DEFAULT false,
    "is_published" BOOLEAN NOT NULL DEFAULT false,
    "retail" DECIMAL(10,2),
    "wholesale" DECIMAL(10,2),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,

    CONSTRAINT "services_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sub_services" (
    "id" UUID NOT NULL,
    "service_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "is_published" BOOLEAN NOT NULL DEFAULT false,
    "retail" DECIMAL(10,2) NOT NULL,
    "wholesale" DECIMAL(10,2),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,

    CONSTRAINT "sub_services_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customers" (
    "id" UUID NOT NULL,
    "store_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "customer_type" "CustomerType" NOT NULL DEFAULT 'CPF',
    "document" VARCHAR(18) NOT NULL,
    "instagram" VARCHAR(255),
    "birth_date" DATE NOT NULL,
    "address" VARCHAR(255) NOT NULL,
    "cep" VARCHAR(255) NOT NULL,
    "complement" VARCHAR(255),
    "neighborhood" VARCHAR(255) NOT NULL,
    "number" VARCHAR(255) NOT NULL,
    "city" VARCHAR(255) NOT NULL,
    "state" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,
    "lgpd_excluded_at" DATE,

    CONSTRAINT "customers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "orders" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "store_id" UUID NOT NULL,
    "retail" DECIMAL(10,2) NOT NULL,
    "wholesale" DECIMAL(10,2),
    "is_wholesale" BOOLEAN NOT NULL DEFAULT false,
    "status" BOOLEAN NOT NULL DEFAULT true,
    "payment_method" "PaymentType" NOT NULL DEFAULT 'CASH',
    "expiration_date" DATE,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,

    CONSTRAINT "orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_service" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "service_id" UUID NOT NULL,
    "retail" DECIMAL(10,2),
    "wholesale" DECIMAL(10,2),
    "subServiceId" UUID,

    CONSTRAINT "order_service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_sub_service" (
    "id" UUID NOT NULL,
    "order_service_id" UUID NOT NULL,
    "service_id" UUID NOT NULL,
    "sub_service_id" UUID NOT NULL,
    "retail" DECIMAL(10,2) NOT NULL,
    "wholesale" DECIMAL(10,2),

    CONSTRAINT "order_sub_service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contacts" (
    "id" UUID NOT NULL,
    "type_entity" "EntityType" NOT NULL,
    "entity_id" UUID NOT NULL,
    "email" TEXT,
    "number" VARCHAR(11) NOT NULL,
    "is_whatsapp" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,
    "lgpd_excluded_at" DATE,

    CONSTRAINT "contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "media" (
    "id" UUID NOT NULL,
    "url" TEXT NOT NULL,
    "alt_text" VARCHAR(255),
    "is_pre_service" BOOLEAN NOT NULL DEFAULT false,
    "entity_type" "EntityMediaType" NOT NULL,
    "entity_id" UUID NOT NULL,
    "media_type_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,
    "lgpd_excluded_at" DATE,

    CONSTRAINT "media_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "media_types" (
    "id" UUID NOT NULL,
    "store_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,

    CONSTRAINT "media_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "appointments" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "store_id" UUID NOT NULL,
    "retail" DECIMAL(10,2) NOT NULL,
    "wholesale" DECIMAL(10,2),
    "is_wholesale" BOOLEAN NOT NULL DEFAULT false,
    "status" BOOLEAN NOT NULL DEFAULT true,
    "payment_method" "PaymentType" NOT NULL DEFAULT 'CASH',
    "expiration_date" DATE,
    "note" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" DATE,

    CONSTRAINT "appointments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "appointment_service" (
    "id" UUID NOT NULL,
    "appointment_id" UUID NOT NULL,
    "service_id" UUID NOT NULL,
    "store_id" UUID NOT NULL,

    CONSTRAINT "appointment_service_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_document_key" ON "users"("document");

-- CreateIndex
CREATE UNIQUE INDEX "stores_document_key" ON "stores"("document");

-- CreateIndex
CREATE UNIQUE INDEX "stores_email_key" ON "stores"("email");

-- CreateIndex
CREATE UNIQUE INDEX "stripe_subscription_store_id_key" ON "stripe_subscription"("store_id");

-- CreateIndex
CREATE UNIQUE INDEX "stripe_subscription_customer_id_key" ON "stripe_subscription"("customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "stripe_subscription_subscription_id_key" ON "stripe_subscription"("subscription_id");

-- CreateIndex
CREATE INDEX "stripe_subscription_subscription_status_idx" ON "stripe_subscription"("subscription_status");

-- CreateIndex
CREATE INDEX "services_store_id_idx" ON "services"("store_id");

-- CreateIndex
CREATE INDEX "sub_services_service_id_idx" ON "sub_services"("service_id");

-- CreateIndex
CREATE UNIQUE INDEX "customers_document_key" ON "customers"("document");

-- CreateIndex
CREATE INDEX "customers_store_id_idx" ON "customers"("store_id");

-- CreateIndex
CREATE UNIQUE INDEX "customers_store_id_document_key" ON "customers"("store_id", "document");

-- CreateIndex
CREATE INDEX "orders_store_id_customer_id_idx" ON "orders"("store_id", "customer_id");

-- CreateIndex
CREATE INDEX "orders_store_id_idx" ON "orders"("store_id");

-- CreateIndex
CREATE INDEX "orders_customer_id_idx" ON "orders"("customer_id");

-- CreateIndex
CREATE INDEX "order_service_order_id_idx" ON "order_service"("order_id");

-- CreateIndex
CREATE INDEX "order_service_service_id_idx" ON "order_service"("service_id");

-- CreateIndex
CREATE INDEX "order_sub_service_service_id_idx" ON "order_sub_service"("service_id");

-- CreateIndex
CREATE INDEX "order_sub_service_sub_service_id_idx" ON "order_sub_service"("sub_service_id");

-- CreateIndex
CREATE UNIQUE INDEX "contacts_email_key" ON "contacts"("email");

-- CreateIndex
CREATE INDEX "contacts_type_entity_idx" ON "contacts"("type_entity");

-- CreateIndex
CREATE INDEX "media_entity_type_entity_id_idx" ON "media"("entity_type", "entity_id");

-- CreateIndex
CREATE UNIQUE INDEX "media_types_store_id_name_key" ON "media_types"("store_id", "name");

-- CreateIndex
CREATE INDEX "appointments_store_id_customer_id_idx" ON "appointments"("store_id", "customer_id");

-- CreateIndex
CREATE INDEX "appointments_store_id_idx" ON "appointments"("store_id");

-- CreateIndex
CREATE INDEX "appointments_customer_id_idx" ON "appointments"("customer_id");

-- CreateIndex
CREATE INDEX "appointment_service_appointment_id_idx" ON "appointment_service"("appointment_id");

-- CreateIndex
CREATE INDEX "appointment_service_service_id_idx" ON "appointment_service"("service_id");

-- CreateIndex
CREATE INDEX "appointment_service_store_id_idx" ON "appointment_service"("store_id");

-- AddForeignKey
ALTER TABLE "users_tokens" ADD CONSTRAINT "users_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stripe_subscription" ADD CONSTRAINT "stripe_subscription_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "services" ADD CONSTRAINT "services_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sub_services" ADD CONSTRAINT "sub_services_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "services"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customers" ADD CONSTRAINT "customers_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_service" ADD CONSTRAINT "order_service_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_service" ADD CONSTRAINT "order_service_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "services"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_service" ADD CONSTRAINT "order_service_subServiceId_fkey" FOREIGN KEY ("subServiceId") REFERENCES "sub_services"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_sub_service" ADD CONSTRAINT "order_sub_service_order_service_id_fkey" FOREIGN KEY ("order_service_id") REFERENCES "order_service"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_sub_service" ADD CONSTRAINT "order_sub_service_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "services"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_sub_service" ADD CONSTRAINT "order_sub_service_sub_service_id_fkey" FOREIGN KEY ("sub_service_id") REFERENCES "sub_services"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "media" ADD CONSTRAINT "media_media_type_id_fkey" FOREIGN KEY ("media_type_id") REFERENCES "media_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "media_types" ADD CONSTRAINT "media_types_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointment_service" ADD CONSTRAINT "appointment_service_appointment_id_fkey" FOREIGN KEY ("appointment_id") REFERENCES "appointments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointment_service" ADD CONSTRAINT "appointment_service_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "services"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointment_service" ADD CONSTRAINT "appointment_service_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "stores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
