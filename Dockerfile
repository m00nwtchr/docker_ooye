ARG NODE_VERSION="20"
ARG OOYE_TAG="v2.1"

FROM node:${NODE_VERSION}-alpine AS source

RUN apk add --no-cache git
RUN git clone --depth=1 --branch=v2.1 https://gitdab.com/cadence/out-of-your-element.git /src
WORKDIR /src

RUN npm ci --omit=dev && npm cache clean --force

FROM node:${NODE_VERSION}-alpine
WORKDIR /app

COPY --from=source /src/ .

RUN adduser ooye -Du 1001
RUN chown -R ooye /app
RUN ln -s /data/ooye.db /app/db/ooye.db
RUN mkdir /data && chown -R ooye:ooye /data
USER ooye

ENV DISCORD_TOKEN="notarealdiscordtoken"
ENV SERVER_NAME="notmyrealserver.com"
ENV SERVER_ORIGIN="https://matrix.notmyrealserver.com"
# Discord Guild ID to upload emojis to, if necessary.
ENV EMOJI_GUILD=""
ENV ADMIN_INVITE=""
ENV CONTENT_LENGTH_WORKAROUND="false"
ENV NAMESPACE_PREFIX="_ooye_"
ENV URL="http://localhost:6693"
# This is the user and channel namespace used when creating user accounts or channels to mirror
# the Discord ones.
# These may be generated with:
# dd if=/dev/urandom bs=32 count=1 2> /dev/null | basenc --base16 | dd conv=lcase 2> /dev/null
ENV HS_TOKEN="[a unique 64 character hex string]"
ENV AS_TOKEN="[a unique 64 character hex string]"

VOLUME /app/db

COPY --chmod=744 --chown=ooye:ooye ./docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
