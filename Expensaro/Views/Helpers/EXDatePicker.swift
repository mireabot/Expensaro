//
//  EXDatePicker.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXDatePicker: View {
  @Binding var currentDate: Date
  @State var currentMonth: Int = 0
  var body: some View {
    VStack(spacing: 15){
      HStack(alignment: .center, spacing: 20){
        VStack(alignment: .leading, spacing: 0) {
          Text(extraDate()[0])
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
          
          Text(extraDate()[1])
            .font(.mukta(.semibold, size: 20))
        }
        
        Spacer(minLength: 0)
        
        Button {
          withAnimation(.interactiveSpring(response: 0.5,dampingFraction: 0.9, blendDuration: 0.9)) {
            currentMonth -= 1
          }
        } label: {
          Image(systemName: "chevron.left")
            .font(.title3)
            .foregroundColor(.primaryGreen)
        }
        
        Button {
          
          withAnimation(.interactiveSpring(response: 0.5,dampingFraction: 0.9, blendDuration: 0.9)) {
            currentMonth += 1
          }
          
        } label: {
          Image(systemName: "chevron.right")
            .font(.title3)
            .foregroundColor(.primaryGreen)
        }
      }
      .padding(.horizontal)
      
      HStack(spacing: 0){
        ForEach(EXDatePicker.days,id: \.self){day in
          
          Text(day)
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
            .frame(maxWidth: .infinity)
        }
      }
      
      LazyVGrid(columns: EXDatePicker.columns,spacing: 5) {
        ForEach(extractDate()){value in
          selectedDate(value: value)
            .background(
              Capsule()
                .fill(Color.primaryGreen)
                .padding(.horizontal,8)
                .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
            )
            .onTapGesture {
              currentDate = value.date
            }
        }
      }
      .transition(.scale)
    }
    .onChange(of: currentMonth) { newValue in
      currentDate = getCurrentMonth()
    }
  }
  
  @ViewBuilder
  func selectedDate(value: DateValue) -> some View {
    VStack{
      if value.day != -1{
        if let payment = RecurrentPayment.recurrentPayments.first(where: { task in
          return isSameDay(date1: task.dueDate, date2: value.date)
        }){
          Text("\(value.day)")
            .font(.mukta(.medium, size: 17))
            .foregroundColor(isSameDay(date1: payment.dueDate, date2: currentDate) ? .white : .primary)
            .frame(maxWidth: .infinity)
          
          Spacer()
          
          Circle()
            .fill(isSameDay(date1: payment.dueDate, date2: currentDate) ? .white : .primaryGreen)
            .frame(width: 8,height: 8)
        }
        else {
          Text("\(value.day)")
            .font(.mukta(.medium, size: 17))
            .foregroundColor(isSameDay(date1: value.date, date2: currentDate) ? .white : .primary)
            .frame(maxWidth: .infinity)
          
          Spacer()
        }
      }
    }
    .padding(.vertical,9)
    .frame(height: 60,alignment: .top)
  }
}

struct EXDatePicker_Previews: PreviewProvider {
  static var previews: some View {
    RecurrentPaymentsListView()
  }
}

// sample Date for Testing...
func getSampleDate(offset: Int)->Date{
  let calender = Calendar.current
  
  let date = calender.date(byAdding: .day, value: offset, to: Date())
  
  return date ?? Date()
}

extension EXDatePicker {
  static let days: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
  static let columns = Array(repeating: GridItem(.flexible()), count: 7)
  
  struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
  }
}

extension EXDatePicker {
  // checking dates...
  func isSameDay(date1: Date,date2: Date)->Bool{
    let calendar = Calendar.current
    
    return calendar.isDate(date1, inSameDayAs: date2)
  }
  
  // extrating Year And Month for display...
  func extraDate()->[String]{
    
    let calendar = Calendar.current
    let month = calendar.component(.month, from: currentDate) - 1
    let year = calendar.component(.year, from: currentDate)
    
    return ["\(year)",calendar.monthSymbols[month]]
  }
  
  func getCurrentMonth()->Date{
    
    let calendar = Calendar.current
    
    // Getting Current Month Date....
    guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
      return Date()
    }
    
    return currentMonth
  }
  
  func extractDate()->[DateValue]{
    
    let calendar = Calendar.current
    
    // Getting Current Month Date....
    let currentMonth = getCurrentMonth()
    
    var days = currentMonth.getAllDates().compactMap { date -> DateValue in
      
      // getting day...
      let day = calendar.component(.day, from: date)
      
      return DateValue(day: day, date: date)
    }
    
    // adding offset days to get exact week day...
    let firstWeekday = calendar.component(.weekday, from: days.first!.date)
    
    for _ in 0..<firstWeekday - 1{
      days.insert(DateValue(day: -1, date: Date()), at: 0)
    }
    
    return days
  }
}
