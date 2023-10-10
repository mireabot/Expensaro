//
//  RecurrentPaymentDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/7/23.
//

import SwiftUI
import ExpensaroUIKit
import PopupView

struct RecurrentPaymentDetailView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  let payment: RecurrentPayment
  
  @State private var isOn = false
  @State private var showDeleteAlert = false
  @State private var showNoteView = false
  @State private var noteText = ""
  var body: some View {
    NavigationView {
      ScrollView {
        // MARK: Transaction header
        VStack(alignment: .leading, spacing: 3) {
          Text(payment.name)
            .font(.mukta(.medium, size: 20))
          
          Text("$\(payment.amount.clean)")
            .font(.mukta(.bold, size: 34))
          
          Text("Next payment date: \(Source.Functions.showString(from: payment.dueDate))")
            .font(.mukta(.regular, size: 15))
            .foregroundColor(.darkGrey)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
        
        // MARK: Transaction detail
        VStack(spacing: 15) {
          HStack {
            payment.category.0
              .foregroundColor(.primaryGreen)
              .padding(8)
              .background(Color.backgroundGrey)
              .cornerRadius(12)
            VStack(alignment: .leading, spacing: -3) {
              Text("Category")
                .font(.mukta(.regular, size: 15))
                .foregroundColor(.darkGrey)
              Text(payment.category.1)
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
            Source.Images.System.calendarYear
              .foregroundColor(.black)
              .padding(8)
            VStack(alignment: .leading, spacing: -3) {
              Text("Periodicity")
                .font(.mukta(.regular, size: 15))
                .foregroundColor(.darkGrey)
              Text(payment.periodicity ?? "N/A")
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
        
        EXToggleCard(type: .paymentReminder, isOn: $isOn)
        
      }
      .onAppear {
        isOn = payment.isReminderTurned ?? false
      }
      .popup(isPresented: $showDeleteAlert) {
        EXAlert(type: .deleteTransaction, primaryAction: {}, secondaryAction: {showDeleteAlert.toggle()}).applyMargins()
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
      .applyMargins()
      .scrollDisabled(true)
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
            showDeleteAlert.toggle()
          } label: {
            Appearance.shared.deleteIcon
              .foregroundColor(.red)
          }
        }
      }
    }
  }
}

struct RecurrentPaymentDetailView_Previews: PreviewProvider {
  static var previews: some View {
    RecurrentPaymentDetailView(payment: RecurrentPayment.recurrentPayments[1])
  }
}

// MARK: - Appearance
extension RecurrentPaymentDetailView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Transactions"
    
    let closeIcon = Source.Images.Navigation.back
    let deleteIcon = Source.Images.ButtonIcons.delete
  }
}

// MARK: - Helper Views
extension RecurrentPaymentDetailView {
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
}
