import com.wms.dao.ProductDAO;
import com.wms.model.Product;
import java.math.BigDecimal;
import java.util.List;

public class TestDAO {
    public static void main(String[] args) {
        try {
            ProductDAO dao = new ProductDAO();
            System.out.println("Testing DAO connection...");
            String testId = "TEST-001";
            if (!dao.productExists(testId)) {
                Product p = new Product(testId, "Test Widget", "Hardware", new BigDecimal("19.99"), 50, "Initial test item");
                boolean added = dao.addProduct(p);
                System.out.println("Product added: " + added);
            }
            List<Product> list = dao.getAllProducts();
            System.out.println("Total products in DB: " + list.size());
            Product p = dao.getProductById(testId);
            System.out.println("Found product: " + p.getName() + ", Qty: " + p.getQuantity());
            
            // Test stock operations
            p = dao.addStock(testId, 25);
            System.out.println("Stock after +25: " + p.getQuantity());
            
            p = dao.reduceStock(testId, 15);
            System.out.println("Stock after -15: " + p.getQuantity());
            
            System.out.println("DAO TEST PASSED SUCCESSFULLY!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
