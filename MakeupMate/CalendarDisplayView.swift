//
//  CalendarView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/04/2023.
//

import SwiftUI
import simd

struct CalendarDisplayView: View {
    
    @Binding var currentDate: Date
    @ObservedObject private var ep = ExpiryProductViewModel()
    
    // Update month when arrow is clicked
    @State var currentMonth: Int = 0
    
    var body: some View {
        VStack(spacing: 20){
            
            //Days
            let days: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            
            // Month display and arrows
            HStack(spacing: 20){
                VStack(alignment: .leading, spacing: 10){
                    
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(extraDate()[1])
                        .font(.title.bold())
                }
                
                Spacer(minLength: 0)
                
                Button {
                    withAnimation{
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
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
            
            // Days display
            HStack(spacing: 0){
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Dates display using LazyGrid
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            // Purple circle for when a day is selected
            LazyVGrid(columns: columns, spacing: 15){
                ForEach(extractDate()){ value in
                    CardView(value: value)
                        .background(
                            // when a day is selected
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
            
            // Displays the expired product
            VStack(spacing: 10){
                Text("Products")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    //.padding(.vertical,20)
                
                if let product = ep.expiredProducts2.first(where: { product in
                    return isSameDay(date1: product.expireDate, date2: currentDate)
                }){
                    ForEach(product.expiryProduct){ product in
                        VStack(alignment: .leading, spacing: 10){
                            Text(product.name)
                                .font(.system(size: 19, weight: .semibold))
                            Text(product.shade)
                                .foregroundColor(Color(.gray))
                                .fontWeight(.semibold)
                            Text(product.brand)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Color("Colour5")
                                .opacity(0.3)
                                .cornerRadius(10))
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
                
                if let product = ep.expiredProducts2.first(where: { product in
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
    
    func getCurrentMonth()->Date{
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        
        return currentMonth
    }
    
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


struct CalendarDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ExpiryCalendarView()
    }
}
