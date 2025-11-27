# GiftBox Backend API

Backend service for the GiftBox e-commerce application, built with Go (Golang), Gin framework, and PostgreSQL.

## 🚀 Tech Stack

- **Language:** Go (Golang)
- **Framework:** Gin Web Framework
- **Documentation:** Swagger (Swaggo)
- **Database:** PostgreSQL (Planned)
- **Containerization:** Docker (Planned)

## 🛠️ Getting Started

Follow these instructions to set up and run the project locally.

### Prerequisites

- Go 1.20+ installed
- Git installed

### Installation & Initialization

1. **Clone the repository**

    ```bash
    git clone <repository-url>
    cd giftbox-backend
    ```

2. **Install Dependencies**

    ```bash
    go mod tidy
    ```

3. **Initialize Swagger Documentation**
    This command generates the necessary Swagger configuration files based on your code annotations.

    ```bash
    swag init -g cmd/api/main.go -o docs
    ```

## 🏃‍♂️ Running the Application

Start the development server:

```bash
go run cmd/api/main.go
```

The server will start on port `8080`.

## 🧪 API Documentation & Testing

We use Swagger for API documentation and interactive testing.

### Accessing Swagger UI

Once the server is running, you can access the Swagger UI at:

👉 **<http://localhost:8080/swagger/index.html>**

### How to Test Endpoints

1. Open the Swagger UI URL in your browser.
2. Expand the **Authentication** section.
3. Click on the `POST /api/v1/auth/login` endpoint.
4. Click the **Try it out** button.
5. Enter the sample payload (or use the default):

    ```json
    {
      "email": "test@example.com",
      "password": "password"
    }
    ```

6. Click **Execute**.
7. Check the **Server response** section to see the status code (e.g., 200) and the response body (e.g., JWT token).

## 📂 Project Structure

```
giftbox-backend/
├── cmd/
│   └── api/
│       └── main.go           # Application entry point
├── docs/                     # Generated Swagger files
├── internal/
│   └── handler/
│       └── auth.go           # Authentication handlers
├── .gitignore
├── go.mod
├── go.sum
└── README.md
```
