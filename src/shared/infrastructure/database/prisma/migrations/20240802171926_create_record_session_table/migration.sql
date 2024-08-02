-- CreateTable
CREATE TABLE "record_sessions" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "session_ip" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expired_in" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "record_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "record_sessions_token_key" ON "record_sessions"("token");

-- AddForeignKey
ALTER TABLE "record_sessions" ADD CONSTRAINT "record_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
