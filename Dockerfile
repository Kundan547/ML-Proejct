# Stage 1: Build Stage
FROM python:3.10 AS builder

# Set the working directory
WORKDIR /app

# Copy only requirements to leverage Docker caching
COPY requirements.txt /app/requirements.txt

# Install dependencies
RUN pip install --user --no-cache-dir -r requirements.txt

# Copy the application code
COPY . /app

# Generate the model file inside the image
RUN python train.py

# Stage 2: Final Stage
FROM python:3.10-slim AS runtime

# Set the working directory
WORKDIR /app

# Copy the installed dependencies from the builder stage
COPY --from=builder /root/.local /root/.local

# Copy the application code from the builder stage
COPY --from=builder /app /app

# Set PATH to use installed dependencies
ENV PATH=/root/.local/bin:$PATH

# Expose the application port
EXPOSE 8000

# Define the command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
