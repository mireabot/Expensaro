//
//  TransactionDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/4/23.
//

import SwiftUI
import ExpensaroUIKit
import PopupView
import Charts

struct TransactionDetailView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  let transaction: Transaction
  
  @State private var showTransactionDeleteAlert = false
  @State private var showNoteView = false
  @State private var noteText = ""
  
  @State private var totalAmountLabel: Float = 0.0
  @State private var transactionsByCategory: [(amount: Float, date: Date)] = []
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        // MARK: Transaction header
        VStack(alignment: .leading, spacing: 3) {
          Text(transaction.name)
            .font(.mukta(.medium, size: 20))
          Text("$\(transaction.amount.clean)")
            .font(.mukta(.bold, size: 34))
          Text(Source.Functions.showString(from: transaction.date))
            .font(.mukta(.regular, size: 15))
            .foregroundColor(.darkGrey)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
        
        // MARK: Transaction detail
        VStack(spacing: 15) {
          HStack {
            transaction.category.0
              .foregroundColor(.primaryGreen)
              .padding(8)
              .background(Color.backgroundGrey)
              .cornerRadius(12)
            VStack(alignment: .leading, spacing: -3) {
              Text("Category")
                .font(.mukta(.regular, size: 15))
                .foregroundColor(.darkGrey)
              Text(transaction.category.1)
                .font(.mukta(.medium, size: 15))
                .foregroundColor(.black)
            }
            Spacer()
            Source.Images.ButtonIcons.selector
              .resizable()
              .frame(width: 20, height: 20)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .onTapGesture {
            // Select new category
          }
          HStack {
            Source.Images.System.transactionType
              .foregroundColor(.black)
              .padding(8)
            VStack(alignment: .leading, spacing: -3) {
              Text("Type")
                .font(.mukta(.regular, size: 15))
                .foregroundColor(.darkGrey)
              Text(transaction.type)
                .font(.mukta(.medium, size: 15))
                .foregroundColor(.black)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(.white)
        .cornerRadius(12)
        .shadowXS()
        
        Button {
          showNoteView.toggle()
        } label: {
          HStack {
            Source.Images.ButtonIcons.edit
              .padding(8)
            VStack(alignment: .leading, spacing: -3) {
              Text("Note")
                .font(.mukta(.regular, size: 15))
                .foregroundColor(.darkGrey)
              Text("Sample note text")
                .font(.mukta(.medium, size: 15))
                .foregroundColor(.black)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(10)
          .background(.white)
          .cornerRadius(12)
          .shadowXS()
        }
        .buttonStyle(EXPlainButtonStyle())
        
        analyticsView()
          .padding(.bottom, 10)
        
      }
      .onAppear {
        let data = calculateSummaryForCategory(categoryToFilter: transaction.category.1)
        transactionsByCategory = data.summaryByDay
        totalAmountLabel = data.totalAmount
      }
      .applyMargins()
      .popup(isPresented: $showTransactionDeleteAlert) {
        EXAlert(type: .deleteTransaction, primaryAction: {}, secondaryAction: {showTransactionDeleteAlert.toggle()}).applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
      .sheet(isPresented: $showNoteView, content: {
        noteView()
          .presentationDetents([.large])
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.closeIcon
              .foregroundColor(.black)
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showTransactionDeleteAlert.toggle()
          } label: {
            Appearance.shared.deleteIcon
              .foregroundColor(.red)
          }
        }
      }
    }
  }
}

struct TransactionDetailView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionDetailView(transaction: Transaction.sampleTransactions[1])
  }
}

// MARK: - Appearance
extension TransactionDetailView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Transactions"
    
    let closeIcon = Source.Images.Navigation.back
    let deleteIcon = Source.Images.ButtonIcons.delete
  }
}

// MARK: - Helper Functions
private extension TransactionDetailView {
  func showTransactionDate(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d, yyyy"
    return formatter.string(from: date)
  }
  
  @ViewBuilder
  func noteView() -> some View {
    NavigationView {
      ScrollView {
        EXResizableTextField(message: $noteText, characterLimit: 300)
          .keyboardType(.alphabet)
      }
      .applyMargins()
      .navigationBarTitleDisplayMode(.inline)
      .safeAreaInset(edge: .bottom) {
        Button {
          showNoteView.toggle()
        } label: {
          Text("Add note")
            .font(.mukta(.semibold, size: 17))
        }
        .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
        .applyMargins()
        .padding(.bottom, 20)
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Create note")
            .font(.mukta(.medium, size: 17))
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showNoteView.toggle()
          } label: {
            Source.Images.Navigation.close
              .foregroundColor(.black)
          }
        }
      }
    }
  }
  
  @ViewBuilder
  func analyticsView() -> some View {
    VStack(alignment: .leading) {
      
      Text("You have spent on ")
        .font(.mukta(.medium, size: 17))
        .foregroundColor(.black)
      + Text(transaction.category.1)
        .font(.mukta(.bold, size: 17))
        .foregroundColor(.primaryGreen)
      + Text(" category")
        .font(.mukta(.medium, size: 17))
        .foregroundColor(.black)
      Text("$\(totalAmountLabel.clean)")
        .font(.mukta(.semibold, size: 24))
      
      Chart {
        ForEach(transactionsByCategory, id: \.date) { transactionData in
          BarMark(
            x: .value("", transactionData.date, unit: .day),
            y: .value("", transactionData.amount),
            width: 40)
          .annotation(position: .top, alignment: .center, spacing: 3) {
            Text("$\(transactionData.amount.clean)")
              .font(.mukta(.medium, size: 15))
          }
          .annotation(position: .bottom, alignment: .center, spacing: 3) {
            Text(Source.Functions.showString(from: transactionData.date))
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
          }
          .foregroundStyle(Color.primaryGreen)
          .cornerRadius(12)
        }
      }
      .chartXAxis(.hidden)
      .chartYAxis(.hidden)
      .frame(height: 200)
      
    }
    .padding(10)
    .background(.white)
    .cornerRadius(12)
    .shadowXS()
  }
  
  func calculateSummaryForCategory(categoryToFilter: String) -> (totalAmount: Float, summaryByDay: [(amount: Float, date: Date)]) {
      var summaryByDay: [String: Float] = [:]
      var totalAmountSpent: Float = 0.0

      for transaction in Transaction.sampleTransactions {
        if transaction.category.1 == categoryToFilter {
              totalAmountSpent += transaction.amount
              
              let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "yyyy-MM-dd"
              let dateString = dateFormatter.string(from: transaction.date)
              
              if let existingAmount = summaryByDay[dateString] {
                  summaryByDay[dateString] = existingAmount + transaction.amount
              } else {
                  summaryByDay[dateString] = transaction.amount
              }
          }
      }
      
      // Convert the summaryByDay dictionary into an array of tuples
      let summaryArray: [(amount: Float, date: Date)] = summaryByDay.map { (key, value) in
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
          if let date = dateFormatter.date(from: key) {
              return (amount: value, date: date)
          }
          return (amount: 0.0, date: Date())
      }
      
      return (totalAmount: totalAmountSpent, summaryByDay: summaryArray)
  }
  
  
}
