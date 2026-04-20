import { defineConfig } from '@prisma/config';

export default defineConfig({
  datasource: {
    url: "postgresql://postgres:1234@localhost:5432/ecoguard_db?schema=public",
  },
});