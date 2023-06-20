//
//  InvitesDatePicker.swift
//  omnii
//
//  Created by huyang on 2023/5/26.
//

import UIKit

struct InvitesDateItem {
    let year: Int       // 年
    let month: Int      // 月
    let day: Int        // 天
    let hour: Int       // 当前小时
    let minute: Int     // 当前分
}

final class InvitesDatePicker: UIView {
    
    private var picker: UIPickerView!

    private let items: [InvitesDateItem]
    private var selectedDay: InvitesDateItem!
    private var selectedHour: Int!
    private var selectedMinute: Int!
    
    var selectedDate: InvitesDateItem {
        get {
            InvitesDateItem(year: selectedDay.year,
                            month: selectedDay.month,
                            day: selectedDay.day,
                            hour: selectedHour,
                            minute: selectedMinute)
        }
    }
    
    required init(items: [InvitesDateItem]) {
        self.items = items
        super.init(frame: .zero)
        
        self.selectedDay = items.first
        self.selectedHour = selectedDay.hour
        self.selectedMinute = selectedDay.minute
        
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        picker.frame = bounds
    }
    
    private func setupViews() {
        
        picker = UIPickerView().then {
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .black
        }
        
        addSubview(picker)
    }

}


extension InvitesDatePicker: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return items.count
        case 1:
            return 24 - selectedDay.hour
        case 2:
            return 60 - selectedDay.minute
        default:
            return 0
        }
    }
    
}

extension InvitesDatePicker: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return (self.width - 50) / 2.0
        case 1:
            return 50.rpx
        case 2:
            return (self.width - 50) / 2.0
        default:
            return .zero
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60.rpx
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        updateSelectView()
        guard let label = view as? PickerLabel else {
            let label = PickerLabel()
            label.textColor = .white
            label.text = updateTitle(forRow: row, forComponent: component)
            return label
        }
        
        label.textColor = .white
        label.text = updateTitle(forRow: row, forComponent: component)
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedDay = items[row]
            pickerView.reloadComponent(1)
            pickerView.reloadComponent(2)
        case 1:
            selectedHour = selectedDay.hour + row
        case 2:
            selectedMinute = selectedDay.minute + row
        default:
            break
        }
    }
    
    private func updateTitle(forRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            if row == 0 { return "Today" }
            if row == 1 { return "Tomorrow" }
            let day = items[row]
            return ("\(day.month)".date(withFormat: "MM")?.monthName(ofStyle: .threeLetters))! + " \(day.day)"
        case 1:
            let hour = "\(selectedDay.hour + row)"
            return hour.count < 2 ? ("0" + hour) : hour
        case 2:
            let minute = "\(selectedDay.minute + row)"
            return minute.count < 2 ? ("0" + minute) : minute
        default:
            return nil
        }
    }
    
    private func updateSelectView() {
        if let selectView = picker.subviews.last, selectView.tag == 111 { return }
        picker.subviews.last?.backgroundColor = .white.withAlphaComponent(0.1)
        picker.subviews.last?.tag = 111
    }
    
}

private class PickerLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = .white
        textAlignment = .center
        font = UIFont(type: .montserratBlod, size: 23.rpx)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
