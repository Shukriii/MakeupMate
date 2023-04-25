//
//  CalendarView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/04/2023.
//

 /*
   To create the custom Calednar view the code was reused and edited from: https://www.youtube.com/watch?v=UZI2dvLoPr8&ab_channel=Kavsoft

   Code from this source was adapted to create the notification: https://www.youtube.com/watch?v=XnnDHDlPwLw&t=204s&ab_channel=PaulHudson
  
   The code was adpated to iterate through ep.expiredProducts, and to display the product details when the its expire date is selected
  
  The user can select to revieve a notification for when a product expires
  */

import SwiftUI
import simd
import UserNotifications

struct CalendarDisplayView: View {
    
    @Binding var currentDate: Date
    @ObservedObject private var ep = ExpiryProductViewModel()
    
    // Update month when arrow is clicked
    @State var currentMonth: Int = 0
    @State var stringProducts = ""
    
    var body: some View {
        VStack(spacing: 20){
            
            // Calendar days
            let days: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            
            // Month display and arrows
            HStack(spacing: 20){
                VStack(alignment: .leading, spacing: 10){
                    
                    // Displays calendar year
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    // Displays calendar motnh
                    Text(extraDate()[1])
                        .font(.title.bold())
                }
                
                Spacer(minLength: 0)
                
                // Back button, goes to the previous month
                Button {
                    withAnimation{
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
                // Forward button, goes to the next month
                Button {
                    withAnimation{
                        currentMonth += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            // Displays calendar days
            HStack(spacing: 0){
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Date columns displayed using LazyGrid
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            // Purple circle shown when a day is selected, the default is the current date
            LazyVGrid(columns: columns, spacing: 15){
                ForEach(extractDate()){ value in
                    CardView(value: value)
                        .background(
                            Capsule()
                                .fill(Color("Colour5"))
                                .padding(.horizontal,8)
                                .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
                        )
                        .onTapGesture {
                            currentDate = value.date
                        }
                }
            }
            
            // Displays the expired product, a NavigationLink to NewEditInventoryProductView wraps the VStack.
            VStack(spacing: 10){
                Text("Products")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                //.padding(.vertical,20)
                
                if let productList = ep.expiredProducts.filter({ product in
                    return isSameDay(date1: product.expireDate, date2: currentDate)
                }){
                    ForEach(productList) { productInfo in
                        
                        ForEach(productInfo.expiryProduct){ product in
                            
                            VStack{
                                HStack {
                                    NavigationLink(destination: NewEditInventoryProductView(productID: product.productID)) {
                                        VStack (alignment: .leading, spacing: 10) {
                                            Text(product.name)
                                                .font(.system(size: 19, weight: .semibold))
                                            Text(product.shade)
                                                .foregroundColor(Color(.gray))
                                                .fontWeight(.semibold)
                                            Text(product.brand)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Bell icon
                                    Button {
                                        // request premission to display an alert, badge and sound
                                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                            if success {
                                                print("premission given")
                                                
                                                let content = UNMutableNotificationContent()
                                                
                                                content.title = "Product Expired Notification"
                                                content.subtitle = "\(product.name) from \(product.brand) will expire today"
                                                content.sound = UNNotificationSound.default
                                                
                                                // used for the trigger
                                                let expireDate = productInfo.expireDate
                                                // FOR USER VERSION, notification is sent 9am on day that it will expire
                                                var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: expireDate)
                                                dateComponents.hour = 9
                                                dateComponents.minute = 00
                                                
                                                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                                                
                                                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                
                                                UNUserNotificationCenter.current().add(request)
                                                
                                            }
                                            else if let error = error {
                                                print(error.localizedDescription)
                                            }
                                            
                                        }
                                        
                                    } label: {
                                        Image(systemName: "bell.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color("Colour5"))
                                    }
                                }
                            }
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    Color("Colour5")
                                        .opacity(0.3)
                                        .cornerRadius(10))
                            
                        }
                    }
                } else {
                    Text("No product found")
                }
            }
            .padding(.horizontal)
        }
        .onChange(of: currentMonth){ newValue in
            //update the month
            currentDate = getCurrentMonth()
        }
    }
    
    // Purple dot if date has an expired product
    @ViewBuilder
    func CardView(value: DateValue)->some View{
        VStack{
            if value.day != -1 {
                
                if let product = ep.expiredProducts.first(where: { product in
                    return isSameDay(date1: product.expireDate, date2: value.date)
                }){
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: product.expireDate, date2: currentDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Circle()
                        .fill(isSameDay(date1: product.expireDate, date2: currentDate) ? .white : Color("Colour5"))
                        .frame(width: 8, height: 8)
                }
                else {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: value.date, date2: currentDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 9)
        .frame(height: 60, alignment: .top)
    }
    
// START - The following functions have been reused from the tutorial - https://www.youtube.com/watch?v=UZI2dvLoPr8&ab_channel=Kavsoft
    
    //checking to see if same day
    func isSameDay(date1: Date, date2: Date)->Bool{
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    //extracting Year and Month for display
    func extraDate()->[String]{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
    
    // returns the current month
    func getCurrentMonth()->Date{
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        
        return currentMonth
    }
    
    // extracts the date from the DateValue Struct
    func extractDate()->[DateValue]{
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap{ date -> DateValue
            in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
            
        }
        
        // adding offset to get extact weekday
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
    }
}

// Extending Date to get current month dates
extension Date{
    func getAllDates()->[Date]{
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
  
        //getting the date
        return range.compactMap{ day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}

// END

struct CalendarDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ExpiryCalendarView()
    }
}
