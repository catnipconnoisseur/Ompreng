import GameplayKit

class FoodBarComponent: GKComponent {
    // Food bar component implementation
    // Menggunakan Set untuk memastikan efisiensi pengecekan duplikasi
    // dan memastikan urutan pengambilan tidak berpengaruh.
    private(set) var collectedFoods = Set<FoodType>()
    
    // Jumlah komponen yang dibutuhkan untuk melengkapi ompreng
    let requiredCount = 5
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Mengecek apakah makanan bisa ditambahkan ke ompreng.
     - Parameter type: Tipe makanan yang akan dicek.
     - Returns: True jika belum ada, False jika sudah ada (memicu penalti).
     */
    func canAddFood(_ type: FoodType) -> Bool {
        return !collectedFoods.contains(type)
    }
    
    /**
     Menambahkan makanan ke dalam koleksi.
     */
    func addFood(_ type: FoodType) {
        collectedFoods.insert(type)
    }
    
    /**
     Mengecek apakah semua komponen (5 jenis makanan) sudah terkumpul.
     */
    func isComplete() -> Bool {
        return collectedFoods.count >= requiredCount
    }
    
    /**
     Mengosongkan ompreng setelah lengkap atau saat reset game.
     */
    func reset() {
        collectedFoods.removeAll()
    }
}
