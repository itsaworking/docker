# Use the official Node.js 16 image from the Docker Hub.
FROM node:16

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
    libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
    libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
    libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
    ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget vim tar curl gnupg2

# Copy API package.json and install dependencies
COPY ./api/package.json /site/api/package.json
RUN cd /site/api && npm install

# Copy Web package.json and install dependencies
COPY ./web/package.json /site/web/package.json
RUN cd /site/web && npm install

# Apply patches for Web
COPY ./web/patches /site/web/patches
RUN cd /site/web && npm run patch-package

# Download and extract GeoLite2-City data
RUN mkdir -p /site/api/data && cd /site/api/data && curl "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=wNKfWihi4Ayoc99a&suffix=tar.gz" --output GeoLite2-City.tar.gz && tar -xvzf GeoLite2-City.tar.gz --strip 1

# Copy all project files
COPY . /site

# Copy ormconfig for production
COPY ./api/ormconfig.prod.yml /site/api/ormconfig.yml

# Build API and Web
RUN cd /site/api && npm run build
RUN cd /site/web && npm run build

# Set working directory and expose port
WORKDIR /site
EXPOSE 80

CMD ["npm", "start", "--prefix", "api"]

