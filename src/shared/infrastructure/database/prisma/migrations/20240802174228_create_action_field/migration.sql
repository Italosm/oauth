-- CreateEnum
CREATE TYPE "Action" AS ENUM ('LOGIN', 'LOGOUT');

-- AlterTable
ALTER TABLE "sessions" ADD COLUMN     "action" "Action" NOT NULL DEFAULT 'LOGIN';
