<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>Application Error</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
  <div class="container mt-5">
    <h1 class="text-danger">Something went wrong</h1>
    <p>An unexpected error occurred while processing your request.</p>
    <hr>
    <h5>Details (for developers)</h5>
    <pre>
<%= exception == null ? "No exception available." : exception.toString() %>
    </pre>
    <a href="/" class="btn btn-primary">Go to Home</a>
  </div>
</body>
</html>
