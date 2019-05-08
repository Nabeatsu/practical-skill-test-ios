//
//  ResponseList.swift
//  practical-skill-test-ios
//
//  Created by 田辺信之 on 2019/05/06.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import Foundation

typealias GetAPIResponse = Either<Either<ConnectionError, TransformError>, [String: TaskInList]?>

typealias PostAPIResponse = Either<Either<ConnectionError, TransformError>, TaskId>

typealias PatchAPIResponse = Either<Either<ConnectionError, TransformError>, UpdatedTask>

typealias DeleteAPIResponse = Either<Either<ConnectionError, TransformError>, DeleteTask?>
