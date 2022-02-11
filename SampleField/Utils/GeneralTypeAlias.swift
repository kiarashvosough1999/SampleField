//
//  GeneralTypeAlias.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import Combine

typealias InFailablePassThroughSubject<T> = PassthroughSubject<T,Never>

typealias InFailableAnyPublisher<T> = AnyPublisher<T,Never>

typealias InFailableCurrentValueSubject<T> = CurrentValueSubject<T,Never>
