<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Submission Successful</title>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        /* General Page Styling */
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f3f7fa;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        /* Success Message Container */
        .container {
            background: #ffffff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.1);
            width: 90%;
            max-width: 400px;
            text-align: center;
        }

        h2 {
            color: #4CAF50;
            margin-bottom: 15px;
        }

        p {
            font-size: 16px;
            color: #555;
            margin-bottom: 20px;
        }

        /* Buttons */
        a {
            display: inline-block;
            background: #4a90e2;
            color: white;
            padding: 10px 15px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            margin: 5px;
            transition: background 0.3s;
        }

        a:hover {
            background: #356ac3;
        }

    </style>
</head>
<body>
    <div class="container">
        <h2>Submission Successful</h2>
        <p>Your complaint has been submitted successfully.</p>
        <a href="student_complaint.jsp">Submit Another Complaint</a>
        <a href="student_dashboard.jsp">Go to Dashboard</a>
    </div>
</body>
</html>
