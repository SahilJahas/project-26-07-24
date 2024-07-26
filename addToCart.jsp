<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>

<%
    HttpSession httpSession = request.getSession();
    if (httpSession == null || httpSession.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userEmail = (String) httpSession.getAttribute("user");

    // Get form parameters
    String productId = request.getParameter("productId");
    String size = request.getParameter("size");

    // JDBC driver name and database URL
    String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    String DB_URL = "jdbc:mysql://192.168.18.245:3306/javadb_168";

    // Database credentials
    String USER = "javadb_168";
    String PASS = "Sp3cJa5A2k24";

    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int userId = -1;

    try {
        // Register JDBC driver
        Class.forName(JDBC_DRIVER);

        // Open a connection
        con = DriverManager.getConnection(DB_URL, USER, PASS);

        // Get the user ID from the user email
        String userSql = "SELECT id FROM vegefoods_user WHERE email = ?";
        pstmt = con.prepareStatement(userSql);
        pstmt.setString(1, userEmail);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            userId = rs.getInt("id");
        }

        // Check if item already exists in the cart for this user
        String checkSql = "SELECT * FROM cart WHERE user_id = ? AND product_id = ?";
        pstmt = con.prepareStatement(checkSql);
        pstmt.setInt(1, userId);
        pstmt.setInt(2, Integer.parseInt(productId));
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // Item already exists in the cart, update quantity if needed
            String updateSql = "UPDATE cart SET quantity = quantity + 1 WHERE user_id = ? AND product_id = ?";
            pstmt = con.prepareStatement(updateSql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, Integer.parseInt(productId));
            pstmt.executeUpdate();
        } else {
            // Insert new item into the cart
            String insertSql = "INSERT INTO cart (user_id, product_id, size, quantity) VALUES (?, ?, ?,)";
            pstmt = con.prepareStatement(insertSql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, Integer.parseInt(productId));
            pstmt.setInt(3, 1); // Default quantity is 1
            pstmt.executeUpdate();
        }

        // Redirect to the cart page
        response.sendRedirect("viewcart.jsp");

    } catch (SQLException se) {
        // Handle errors for JDBC
        se.printStackTrace();
    } catch (Exception e) {
        // Handle errors for Class.forName
        e.printStackTrace();
    } finally {
        // Finally block to close resources
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException se) {
            se.printStackTrace();
        }
    }
%>