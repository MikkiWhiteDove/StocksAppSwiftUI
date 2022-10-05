//
//  ContentViewModel.swift
//  StocksApp
//
//  Created by Mishana on 03.10.2022.
//

import SwiftUI
import Foundation
import Combine
import CoreData


final class ContentViewModel: ObservableObject {
    
    private let context = PersistenceController.shared.container.viewContext
    
    @Published var stockData: [Stocks] = []
    @Published var symbol = ""
    @Published var stockEntities: [StockEntity] = []
    @Published var symbolValidate = false
    
    private var cancellables = Set<AnyCancellable>()
    
    let APIKEY = "M8DZREA2JS4KG5NJ"
    
    init() {
//        loadAllSymbols()
        loadCoreData()
        loadAllSymbols()
        validateSymbol()
    }
    
    func validateSymbol() {
        $symbol
            .sink { [unowned self]newValue in
                self.symbolValidate = !newValue.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func loadCoreData() {
        do {
            stockEntities =  try context.fetch(StockEntity.fetchRequest())
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func addStock() {
        let newStock = StockEntity(context: context)
        newStock.symbol = symbol
        
        do{
            try context.save()
        }catch {
            print(error.localizedDescription)
        }
        stockEntities.append(newStock)
        getStockData(for: symbol)
        symbol = ""
    }
    
    func deleteStock(at indexSet: IndexSet) {
        guard let index = indexSet.first else {return}
        
        stockData.remove(at: index)
        let stockRemove = stockEntities.remove(at: index)
        
        context.delete(stockRemove)
        
        do {
            
            try context.save()
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func loadAllSymbols() {
        stockData = []
        stockEntities.forEach{ stockEntity in
            getStockData(for: stockEntity.symbol ?? "")
        }
    }
    
    func getStockData(for symbol: String) {
        guard let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=5min&apikey=\(APIKEY)") else { return }
    
        URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: Stocks.self, decoder: JSONDecoder())
            .sink{ completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    return
                case .finished:
                    return
                }
            }receiveValue: { [unowned self] stockData in
                DispatchQueue.main.async {
                    self.stockData.append(stockData)
                }
            }
            .store(in: &cancellables)
    }
    
}

//let APIKEY = ""
