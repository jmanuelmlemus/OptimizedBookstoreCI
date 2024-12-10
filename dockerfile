# Example Dockerfile
FROM python:3.10-slim as builder

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy only the requirements to leverage Docker's caching mechanism
COPY requirements.txt .

#Install dependencies to a temporary locations
RUN pip install --user --no-cache-dir -r requirements.txt

#stage 2: runtime stage
FROM python:3.10-slim

#Set the working directory inside the container
WORKDIR /usr/src/app

# copy the application files into the container
COPY . .

#Copy the dependencies installed in the builder
COPY --from=builder /root/.local /root/.local

# Copy the wait-for-it.sh script from the scripts folder
COPY scripts/wait-for-it.sh /usr/src/app/

# Ensure the script has executable permissions
RUN chmod +x /usr/src/app/wait-for-it.sh

# update Path to include pip binaries installed in the user's directory
ENV PATH="/root/.local/bin:$PATH"

# Default command to start the app
CMD ["./wait-for-it.sh", "db:5432", "--", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
