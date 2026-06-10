## Multi-stage Dockerfile for building and running a Phoenix (Elixir) release
FROM hexpm/elixir:1.14.4-erlang-26.2.4-alpine AS build
WORKDIR /app

# install build tools
RUN apk add --no-cache build-base git nodejs npm postgresql-client bash

# cache deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix local.rebar --force && mix local.hex --force
RUN mix deps.get --only prod

# copy the rest and compile
COPY . .
RUN MIX_ENV=prod mix deps.compile
RUN MIX_ENV=prod mix compile

# assets (if any) - keep simple: build assets if package.json present
RUN if [ -f assets/package.json ]; then \
  cd assets && npm ci && npm run deploy; \
  mix phx.digest; \
  fi

RUN MIX_ENV=prod mix release --overwrite

FROM alpine:3.18
RUN apk add --no-cache libstdc++ openssl ncurses-libs musl tzdata ca-certificates postgresql-client
WORKDIR /app
ENV MIX_ENV=prod

COPY --from=build /app/_build/prod/rel/tag_ip .
EXPOSE 4000
CMD ["/app/bin/tag_ip", "start"]
