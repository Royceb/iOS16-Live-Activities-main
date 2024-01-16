//
//  PriceAlertsLiveActivity.swift
//  PriceAlerts
//
//  Created by Royce Brooks on 1/13/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Widgets: WidgetBundle {
    var body: some Widget {
        PriceAlertLiveActivityWidget()
    }
}

struct PriceAlertAttributesNew: ActivityAttributes {
    public typealias PriceAlertLiveActivity = ContentState

    public struct ContentState: Codable, Hashable {
         var driverName: String
     }
    
    let assetName: String
    let assetTicker: String
    let price: Double
    let percentChange: Double
}

// CryptoData structure for a single cryptocurrency asset
struct CryptoData {
    let name: String
    let currentPrice: Double
    let percentageChange: Double
}

// CryptoPricePoint structure for the price data points in our chart
struct CryptoPricePoint {
    let time: Date
    let price: Double
}


struct CryptoChartView: View {
    let cryptoData: CryptoData
    let pricePoints: [CryptoPricePoint]

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(cryptoData.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer() // This will push the name to the top
                    Spacer() // This will push the name to the top
                    Spacer() // This will push the name to the top
                    GeometryReader { geometry in
                        let maxPrice = pricePoints.max(by: { $0.price < $1.price })?.price ?? 1
                        let minPrice = pricePoints.min(by: { $0.price < $1.price })?.price ?? 0
                        let priceRange = maxPrice - minPrice
                        
                        Path { path in
                            for (index, pricePoint) in pricePoints.enumerated() {
                                let xPosition = geometry.size.width / CGFloat(pricePoints.count - 1) * CGFloat(index)
                                let yPosition = (1 - CGFloat((pricePoint.price - minPrice) / priceRange)) * geometry.size.height
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: xPosition, y: yPosition))
                                } else {
                                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                                }
                            }
                        }
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 10)
                        
                        let gradient = LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.2), .clear]), startPoint: .top, endPoint: .bottom)
                        let area = Path { path in
                            path.move(to: CGPoint(x: 0, y: geometry.size.height))
                            for (index, pricePoint) in pricePoints.enumerated() {
                                let xPosition = geometry.size.width / CGFloat(pricePoints.count - 1) * CGFloat(index)
                                let yPosition = (1 - CGFloat((pricePoint.price - minPrice) / priceRange)) * geometry.size.height
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: xPosition, y: yPosition))
                                } else {
                                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                                }
                            }
                            path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                            path.closeSubpath()
                        }
                        area.fill(gradient)
                    }
                }
                
                Spacer() // This spacer will ensure that the name and price are on the opposite sides.
                VStack(alignment: .trailing) {
                    Text(String(format: "$%.2f", cryptoData.currentPrice))
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    Text(String(format: "%.2f%%", cryptoData.percentageChange))
                        .foregroundColor(cryptoData.percentageChange > 0 ? .green : .red).font(.footnote)
                }
            }
            .padding([.horizontal])
        }
        .padding()
        .background(Color.black)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}


struct PriceAlertLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
       ActivityConfiguration(for: PriceAlertAttributesNew.self) { context in
         // Lock screen/banner UI goes here
         VStack {
           CryptoChartView(
             cryptoData:
               CryptoData(name: "BTC", currentPrice: 30016, percentageChange: 31.4),
             pricePoints: [
               CryptoPricePoint(time: Date().addingTimeInterval(-300), price: 10),
               CryptoPricePoint(time: Date().addingTimeInterval(-240), price: 200),
               CryptoPricePoint(time: Date().addingTimeInterval(-180), price: 3),
               CryptoPricePoint(time: Date().addingTimeInterval(-120), price: 939),
               CryptoPricePoint(time: Date().addingTimeInterval(-60), price: 1),
               CryptoPricePoint(time: Date(), price: 0.5),
             ]
           )
           .frame()  // Set the frame height as needed
         }
         .activitySystemActionForegroundColor(Color.black)

       } dynamicIsland: { context in
         DynamicIsland {
           // Expanded UI goes here. Compose the expanded UI through
           // various regions, like leading/trailing/center/bottom
           DynamicIslandExpandedRegion(.leading) {
               Button("Buy", action: {})

           }
           DynamicIslandExpandedRegion(.trailing) {
               Button("Sell", action: {})

           }
           DynamicIslandExpandedRegion(.bottom) {
             // Here you could also include a more compact version of the chart or just textual data
             CryptoChartView(
               cryptoData:
                 CryptoData(name: "BTC", currentPrice: 30016, percentageChange: 3.4),
               pricePoints: [
                 CryptoPricePoint(time: Date().addingTimeInterval(-300), price: 0.3),
                 CryptoPricePoint(time: Date().addingTimeInterval(-240), price: 0.5),
                 CryptoPricePoint(time: Date().addingTimeInterval(-180), price: 0.4),
                 CryptoPricePoint(time: Date().addingTimeInterval(-120), price: 0.6),
                 CryptoPricePoint(time: Date().addingTimeInterval(-60), price: 0.7),
                 CryptoPricePoint(time: Date(), price: 0.5),
               ]
             )
             .frame()  // Adjust height for Dynamic Island's bottom area
           }
         } compactLeading: {
           Text("BTC")
         } compactTrailing: {
           Text("+3.28%")
         } minimal: {
           Text("BTC")
         }
         .widgetURL(URL(string: "http://www.apple.com"))
         .keylineTint(Color.red)
       }
     }
}

// Preview available on iOS 16.2 or above
@available(iOSApplicationExtension 16.2, *)
struct PriceAlertLiveActivityWidget_Previews: PreviewProvider {
    static let activityAttributes = PriceAlertAttributesNew(assetName: "bitcoin", assetTicker: "btc", price: 20, percentChange: 20)
    static let activityState = PriceAlertAttributesNew.ContentState(driverName: "test")
    
    static var previews: some View {
        activityAttributes
            .previewContext(activityState, viewKind: .content)
            .previewDisplayName("Notification")
        
        activityAttributes
            .previewContext(activityState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Compact")
        
        activityAttributes
            .previewContext(activityState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Expanded")
        
        activityAttributes
            .previewContext(activityState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
    }
}
