FROM alpine:latest

# Install bash for the script's shebang and dos2unix for line endings
RUN apk add --no-cache bash dos2unix

# Copy the script into the container
COPY autopalpine-v1.sh /app/autopalpine-v1.sh

# Convert line endings from Windows (CRLF) to Unix (LF)
RUN dos2unix /app/autopalpine-v1.sh

# Set the working directory
WORKDIR /app

# Make the script executable
RUN chmod +x autopalpine-v1.sh

# Set the default command to keep the container running (optional, depends on use case)
# Or you can specify the command directly in docker-compose
# CMD ["tail", "-f", "/dev/null"] 