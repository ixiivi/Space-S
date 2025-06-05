//
//  CPMService.swift
//  Space S
//
//  Created by 김재현 on 6/4/25.
//

import Foundation

// CPM 계산을 위한 활동을 나타내는 구조체입니다.
// SwiftData 모델과 독립적으로 계산 로직에 사용됩니다.
struct CPMActivity: Identifiable, Hashable {
    let id: String // 활동의 고유 식별자
    var name: String // 활동 이름
    var duration: Int // 활동 기간 (일(day) 단위로 가정)

    var predecessorIDs: Set<String> // 이 활동 이전에 완료되어야 하는 활동들의 ID 집합
    var successorIDs: Set<String> = [] // 이 활동 이후에 시작될 수 있는 활동들의 ID 집합 (자동 계산됨)

    // CPM 계산 결과 값
    var earlyStart: Int = 0
    var earlyFinish: Int = 0
    var lateStart: Int = 0
    var lateFinish: Int = 0
    var slack: Int = 0 // 여유 시간 (LS - ES 또는 LF - EF)
    var isCritical: Bool = false // 중요 활동 여부 (slack == 0)

    init(id: String, name: String, duration: Int, predecessors: Set<String> = []) {
        self.id = id
        self.name = name
        self.duration = duration
        self.predecessorIDs = predecessors
    }

    // Hashable 준수를 위한 구현
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CPMActivity, rhs: CPMActivity) -> Bool {
        return lhs.id == rhs.id
    }
}

class CPMService {

    /**
     주어진 활동 목록에 대해 CPM 분석을 수행합니다.
     - Parameter activities: CPM 분석을 수행할 `CPMActivity` 객체의 배열입니다.
     - Returns: ES, EF, LS, LF, slack, isCritical 값이 모두 계산된 `CPMActivity` 객체의 배열을 반환합니다.
                입력 배열이 비어있거나 순환 종속성이 감지되면 적절히 처리된 결과를 반환할 수 있습니다.
     */
    func calculateCPM(activities: [CPMActivity]) -> [CPMActivity] {
        guard !activities.isEmpty else { return [] }

        var activityMap = buildActivityMap(from: activities)
        linkSuccessors(activityMap: &activityMap)

        // 위상 정렬을 사용하여 활동 처리 순서를 결정합니다.
        let sortedActivityIDs = topologicalSort(activityMap: activityMap)
        
        // 순환 종속성 등으로 위상 정렬 실패 시 빈 배열 반환 (또는 오류 처리)
        guard sortedActivityIDs.count == activityMap.count else {
            print("CPM Calculation Error: Cycle detected or graph error. Cannot proceed.")
            // 필요에 따라 오류를 throw 하거나 다른 방식으로 처리할 수 있습니다.
            // 현재는 빈 배열을 반환하여 계산 실패를 알립니다.
            return []
        }

        // 전진 계산 (Forward Pass)
        performForwardPass(activityMap: &activityMap, sortedActivityIDs: sortedActivityIDs)

        // 프로젝트 총 완료 시간 계산
        let projectFinishTime = calculateProjectFinishTime(from: activityMap)

        // 후진 계산 (Backward Pass)
        performBackwardPass(activityMap: &activityMap, sortedActivityIDs: sortedActivityIDs, projectFinishTime: projectFinishTime)

        // 여유 시간 및 중요 경로 계산
        calculateSlackAndCriticalPath(activityMap: &activityMap)
        
        // 결과를 ES 기준으로 정렬하여 반환 (동일한 ES의 경우 ID로 정렬)
        return Array(activityMap.values).sorted {
            if $0.earlyStart != $1.earlyStart {
                return $0.earlyStart < $1.earlyStart
            }
            return $0.id < $1.id
        }
    }

    // 활동 배열을 ID를 키로 하는 딕셔너리(맵)로 변환합니다.
    private func buildActivityMap(from activities: [CPMActivity]) -> [String: CPMActivity] {
        var map = [String: CPMActivity]()
        for activity in activities {
            map[activity.id] = activity
        }
        return map
    }

    // 각 활동의 predecessorIDs를 기반으로 successorIDs를 설정합니다.
    private func linkSuccessors(activityMap: inout [String: CPMActivity]) {
        // 먼저 모든 successorIDs를 초기화합니다.
        for id in activityMap.keys {
            activityMap[id]?.successorIDs = []
        }
        
        for (id, activity) in activityMap {
            for predecessorID in activity.predecessorIDs {
                // 선행 활동이 맵에 존재하는지 확인합니다.
                if activityMap[predecessorID] != nil {
                    activityMap[predecessorID]!.successorIDs.insert(id)
                } else {
                    print("Warning: Predecessor ID '\(predecessorID)' for activity '\(id)' not found in activity map.")
                }
            }
        }
    }
    
    // 위상 정렬 (Kahn's Algorithm)을 수행하여 활동 처리 순서를 반환합니다.
    // 순환이 감지되면 실제 활동 수보다 적은 수의 ID를 가진 배열을 반환할 수 있습니다.
    private func topologicalSort(activityMap: [String: CPMActivity]) -> [String] {
        var sortedOrder: [String] = []
        var inDegree: [String: Int] = [:] // 각 노드의 진입 차수
        var queue: [String] = [] // 진입 차수가 0인 노드를 담을 큐

        // 모든 활동에 대해 진입 차수를 0으로 초기화합니다.
        for id in activityMap.keys {
            inDegree[id] = 0
        }

        // 각 활동의 후행 활동을 기반으로 진입 차수를 계산합니다.
        for activity in activityMap.values {
            for succID in activity.successorIDs {
                inDegree[succID, default: 0] += 1
            }
        }

        // 진입 차수가 0인 활동들을 큐에 추가합니다. (결정성을 위해 ID로 정렬)
        for id in activityMap.keys.sorted() { // .keys.sorted() 추가
            if inDegree[id] == 0 {
                queue.append(id)
            }
        }
        
        // 큐가 빌 때까지 반복합니다.
        while !queue.isEmpty {
            let u = queue.removeFirst() // 큐에서 활동을 하나 꺼냅니다.
            sortedOrder.append(u) // 정렬된 목록에 추가합니다.

            // 현재 활동(u)의 모든 후행 활동(v)에 대해 반복합니다.
            // 결정성을 위해 후행 활동 ID를 정렬합니다.
            let sortedSuccessors = activityMap[u]?.successorIDs.sorted() ?? []
            for v in sortedSuccessors {
                inDegree[v, default: 0] -= 1 // 후행 활동의 진입 차수를 1 감소시킵니다.
                if inDegree[v] == 0 { // 만약 후행 활동의 진입 차수가 0이 되면
                    queue.append(v) // 큐에 추가합니다.
                }
            }
            // 큐에 여러 요소가 있을 경우 일관된 순서를 위해 정렬합니다.
            if queue.count > 1 { queue.sort() }
        }

        // 만약 정렬된 목록의 활동 수가 전체 활동 수와 다르면, 그래프에 순환이 있는 것입니다.
        if sortedOrder.count != activityMap.count {
            print("Error: Cycle detected in the activity graph. Topological sort incomplete.")
            // 순환 감지 시, 빈 배열 대신 sortedOrder를 그대로 반환하여
            // calculateCPM 함수에서 처리하도록 합니다.
        }
        return sortedOrder
    }

    // 전진 계산: 각 활동의 ES(Early Start)와 EF(Early Finish)를 계산합니다.
    private func performForwardPass(activityMap: inout [String: CPMActivity], sortedActivityIDs: [String]) {
        for activityID in sortedActivityIDs {
            guard var currentActivity = activityMap[activityID] else { continue }

            var maxEFOfPredecessors = 0
            if currentActivity.predecessorIDs.isEmpty {
                // 선행 활동이 없는 경우 (프로젝트 시작 활동) ES는 0입니다.
                maxEFOfPredecessors = 0
            } else {
                for predID in currentActivity.predecessorIDs {
                    if let predecessor = activityMap[predID] {
                        maxEFOfPredecessors = max(maxEFOfPredecessors, predecessor.earlyFinish)
                    }
                }
            }
            
            currentActivity.earlyStart = maxEFOfPredecessors
            currentActivity.earlyFinish = currentActivity.earlyStart + currentActivity.duration
            activityMap[activityID] = currentActivity
        }
    }
    
    // 프로젝트의 전체 완료 시간 (모든 활동 중 가장 큰 EF 값)을 계산합니다.
    private func calculateProjectFinishTime(from activityMap: [String: CPMActivity]) -> Int {
        return activityMap.values.map { $0.earlyFinish }.max() ?? 0
    }

    // 후진 계산: 각 활동의 LS(Late Start)와 LF(Late Finish)를 계산합니다.
    private func performBackwardPass(activityMap: inout [String: CPMActivity], sortedActivityIDs: [String], projectFinishTime: Int) {
        // 위상 정렬된 순서의 역순으로 처리합니다.
        for activityID in sortedActivityIDs.reversed() {
            guard var currentActivity = activityMap[activityID] else { continue }

            if currentActivity.successorIDs.isEmpty {
                // 후행 활동이 없는 경우 (프로젝트 종료 활동) LF는 프로젝트 완료 시간과 같습니다.
                currentActivity.lateFinish = projectFinishTime
            } else {
                var minLSOfSuccessors = Int.max
                for succID in currentActivity.successorIDs {
                    if let successor = activityMap[succID] {
                        minLSOfSuccessors = min(minLSOfSuccessors, successor.lateStart)
                    }
                }
                // minLSOfSuccessors가 Int.max라는 것은 후행 작업이 있지만, 그 작업들의 LS가 아직 계산되지 않았거나
                // 연결에 문제가 있을 수 있음을 의미할 수 있으나, 정상적인 경우라면 이 값은 설정되어야 합니다.
                // 여기서는 Int.max가 그대로 남아있다면 프로젝트 종료 시간을 사용합니다.
                currentActivity.lateFinish = (minLSOfSuccessors == Int.max) ? projectFinishTime : minLSOfSuccessors
            }
            
            currentActivity.lateStart = currentActivity.lateFinish - currentActivity.duration
            activityMap[activityID] = currentActivity
        }
    }

    // 각 활동의 여유 시간(slack)을 계산하고 중요 활동(critical) 여부를 결정합니다.
    private func calculateSlackAndCriticalPath(activityMap: inout [String: CPMActivity]) {
        for id in activityMap.keys {
            guard var activity = activityMap[id] else { continue }
            activity.slack = activity.lateStart - activity.earlyStart // LF - EF 와 동일
            activity.isCritical = activity.slack == 0
            activityMap[id] = activity
        }
    }
}
