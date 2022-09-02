import UIKit

enum VehicleType {
    case car
    case moto
    case miniBus
    case bus
    
    var hourFee: Int {
        switch self {
        case .car: return 20
        case .moto: return 15
        case .miniBus: return 25
        case .bus: return 30
        }
    }
}

protocol Parkable {
    var plate: String { get }
    var type: VehicleType { get }
    var checkIn: Date { get }
    var discountCard: String? { get }
    var mins: Int { get }
}

struct Vehicle: Parkable, Hashable {
    
    let plate: String
    let type: VehicleType
    let checkIn: Date
    let discountCard: String?
    
    var mins: Int {
        return Calendar.current.dateComponents([.minute], from: checkIn, to: Date()).minute ?? 0
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.plate == rhs.plate
    }
}

struct Parking {
    var vehicles: Set<Vehicle> = []
    var limit: Int = 7
    var registerVehicles: Int = 0
    var registerEarnings: Int = 0
    
    mutating func checkinVehicle(vehicle: Vehicle, vehicleAdded: (Bool) -> Void) {
        if vehicles.count < limit {
            vehicles.insert(vehicle)
            vehicleAdded(true)
        } else { vehicleAdded(false) }
    }
    
    mutating func checkOutVehicle(plate: String, onSuccess: (Int) -> Void, onError: () -> Void) {
        guard let vehicle = vehicles.first(where: { $0.plate == plate }) else {
            onError()
            return
        }
        let hasDiscound = vehicle.discountCard != nil
        let fee = calculateFee(type: vehicle.type, parkedTime: vehicle.mins, hasDiscountCard: hasDiscound)
        vehicles.remove(vehicle)
        registerVehicles += 1
        registerEarnings += fee
        onSuccess(fee)
    }
    
    func calculateFee(type: VehicleType, parkedTime: Int, hasDiscountCard: Bool) -> Int {
        var fee = type.hourFee
        if parkedTime > 120 {
            let reminderMins = parkedTime - 120
            fee += Int(ceil(Double(reminderMins) / 15.0)) * 5
        }
        if hasDiscountCard {
            fee = Int(Double(fee) * 0.85)
        }
        return fee
    }
    
    func showEarnings() {
        print("\(registerVehicles) Vehiculos registrados")
        print("Total recaudado $\(registerEarnings)")
    }
    
    func listVehicles() {
        for vehicle in vehicles {
            print("Vehiculo: \(vehicle.plate)")
        }
    }
}



var alkeParking = Parking()
let vehicles: [Vehicle] = [.init(plate: "MAH5071", type: .car, checkIn: Date(), discountCard: "card001"),
                           .init(plate: "LKC2022", type: .car, checkIn: Date(), discountCard: "card002"),
                           .init(plate: "SBS1014", type: .bus, checkIn: Date(), discountCard: nil),
                           .init(plate: "KLM4432", type: .miniBus, checkIn: Date(), discountCard: nil),
                           .init(plate: "MOP3098", type: .car, checkIn: Date(), discountCard: "card003"),
                           .init(plate: "NTO2929", type: .moto, checkIn: Date(), discountCard: "card004"),
                           .init(plate: "OPA032", type: .moto, checkIn: Date(), discountCard: nil),
                           .init(plate: "MHA5000", type: .moto, checkIn: Date(), discountCard: "card005"),
                           .init(plate: "MHA5000", type: .moto, checkIn: Date(), discountCard: "card005")]
for vehicle in vehicles {
    alkeParking.checkinVehicle(vehicle: vehicle) { vehicleAdded in vehicleAdded ? print("Bienvenido: \(vehicle.plate)") : print("No hay lugar") }
}



alkeParking.checkOutVehicle(plate: "OPA032") { amount in
    print("total a pagar: \(amount)")
} onError: {
    print("Hubo un error")
}

alkeParking.showEarnings()
alkeParking.listVehicles()
