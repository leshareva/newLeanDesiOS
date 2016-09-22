//
//  LayoutPriority.swift
//  Swiftstraints
//
//  Created by Bradley Hilton on 6/15/16.
//  Copyright © 2016 Skyvive. All rights reserved.
//

public enum LayoutPriority {
    
    case Required
    case High
    case Low
    case FittingSizeLevel
    case Other(UILayoutPriority)
    
    var priority: UILayoutPriority {
        switch self {
        case .Required: return UILayoutPriorityRequired
        case .High: return UILayoutPriorityDefaultHigh
        case .Low: return UILayoutPriorityDefaultLow
        case .FittingSizeLevel: return UILayoutPriorityFittingSizeLevel
        case .Other(let priority): return priority
        }
    }
    
}

public func |(lhs: AxisAnchor, rhs: LayoutPriority) -> AxisAnchor {
    return CompoundAxis(anchor: lhs.anchor, constant: lhs.constant, priority: rhs)
}

public func |(dimension: DimensionAnchor, priority: LayoutPriority) -> DimensionAnchor {
    return CompoundDimension(dimension: dimension.dimension, multiplier: dimension.multiplier, constant: dimension.constant, priority: priority)
}

public struct PrioritizedConstant {
    let constant: CGFloat
    let priority: LayoutPriority
}

public func |(constant: CGFloat, priority: LayoutPriority) -> PrioritizedConstant {
    return PrioritizedConstant(constant: constant, priority: priority)
}
