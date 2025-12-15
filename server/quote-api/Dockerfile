FROM mcr.microsoft.com/playwright:v1.46.0-jammy

ENV NODE_ENV=production
WORKDIR /app

# Install dependencies
COPY package.json ./
RUN npm install --omit=dev && npm cache clean --force

# Copy source
COPY server.js ./
COPY src ./src
COPY templates ./templates

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl --fail --silent http://localhost:3000 || exit 1

CMD ["node", "server.js"]
