FROM alpine:3.19

# Install PostgreSQL client tools
RUN apk add --no-cache postgresql-client

# Copy the initialization script
COPY init.sh /init.sh

# Make it executable
RUN chmod +x /init.sh

# Run the initialization script
ENTRYPOINT ["/init.sh"]