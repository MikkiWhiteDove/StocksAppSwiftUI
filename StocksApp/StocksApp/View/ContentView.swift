//
//  ContentView.swift
//  StocksApp
//
//  Created by Mishana on 01.10.2022.
//

import SwiftUI
//import CoreData

struct ContentView: View {
    @ObservedObject private var model = ContentViewModel()
    private let colorRed: [Color] = [.red.opacity(0.8), .red.opacity(0.5), .red.opacity(0)]
    private let colorGreen: [Color] = [.green.opacity(0.8), .green.opacity(0.5), .green.opacity(0)]

    var body: some View {
        NavigationView {
            List {
                HStack{
                    TextField("Symbol", text: $model.symbol)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add", action: model.addStock)
                        .disabled(!model.symbolValidate)
                }
                .padding(.bottom, 10)
                if !model.stockData.isEmpty{
                    ForEach(model.stockData) { stock in
                        HStack{
                            Text(stock.metaData.symbol)
                            Spacer()
                            LineChart(values: stock.closeValues)
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: stock.openClose ? colorGreen : colorRed),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 100, height: 50)
//                            RoundedRectangle(cornerRadius: 10)
//                                .frame(width: 150, height: 50)
                            VStack(alignment: .trailing){
                                Text(stock.latestClose)
                            }
                            .frame(width: 100)
                        }
                    }
                    .onDelete(perform: model.deleteStock(at:))
                }
            }
            .navigationTitle("Stocks")
            .toolbar{
                ToolbarItem(placement: .primaryAction){
                    EditButton()
                }
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
