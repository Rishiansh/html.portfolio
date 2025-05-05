<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Submit Complaint</title>
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

        /* Form Container */
        .container {
            background: #ffffff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.1);
            width: 90%;
            max-width: 450px;
            text-align: center;
        }

        h2 {
            color: #4a90e2;
            margin-bottom: 20px;
        }

        /* Input Fields */
        label {
            display: block;
            text-align: left;
            font-weight: bold;
            margin-top: 12px;
            color: #333;
        }

        input, select, textarea {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
        }

        textarea {
            resize: none;
            height: 100px;
        }

        /* File Upload */
        input[type="file"] {
            border: none;
        }

        /* Submit Button */
        button {
            width: 100%;
            padding: 12px;
            background: #4a90e2;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 15px;
            transition: background 0.3s;
        }

        button:hover {
            background: #356ac3;
        }

    </style>
</head>
<body>
    <div class="container">
        <h2>Submit a Complaint</h2>
        <form action="SubmitComplaintServlet" method="post" enctype="multipart/form-data">
            
            <label for="name">Your Name:</label>
            <input type="text" name="name" placeholder="Enter your full name" required>

            <label for="email">Email:</label>
            <input type="email" name="email" placeholder="Enter your email" required>

            <label for="department">Select Department:</label>
            <select name="department" required>
                <option value="" disabled selected>Select a department</option>
                <option value="VC">VC</option>
                <option value="Admission Cell">Admission Cell</option>
                <option value="Examination Cell">Examination Cell</option>
                <option value="Accounts">Accounts</option>
                <option value="HOD">HOD</option>
            </select>

            <label for="complaint">Complaint Description:</label>
            <textarea name="complaint" placeholder="Describe your issue..." required></textarea>

            <label for="file">Upload File (Optional):</label>
            <input type="file" name="file" accept="image/*,application/pdf">

            <button type="submit">Submit Complaint</button>
        </form>
    </div>
</body>
</html>
