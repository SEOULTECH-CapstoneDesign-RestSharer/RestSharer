//
//  PrivacyPolicyView.swift
//  RestSharer
//
//  Created by 강민수 on 10/16/24.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                Text("개인정보 처리방침")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("1. 개인정보의 수집 및 이용 목적")
                    .font(.headline)
                    .padding(.top, 5)
                Text("""
사용자의 개인정보는 다음의 목적을 위해 수집 및 이용됩니다:
- E-mail: 계정 생성, 비밀번호 재설정, 서비스 관련 공지사항 전달
- 전화번호: 본인 확인, 계정 복구, 고객 지원
- 닉네임: 서비스 내 사용자 식별 및 사용자 경험 향상
- 위치 정보: 위치 기반 서비스 제공 및 개인 맞춤형 추천 서비스 제공
- 프로필 사진 (선택 사항): 사용자 계정 개인화 및 커뮤니티 상호작용 증대
- 이용 기록: 마커 저장 및 추천 기록을 통해 개인 맞춤형 콘텐츠 제공
""")
                
                Text("2. 개인정보의 처리 및 보유 기간")
                    .font(.headline)
                    .padding(.top, 5)
                Text("""
사용자의 개인정보는 서비스 이용 기간 동안 또는 법령에서 정한 보유 기간 동안 보유됩니다. 개인정보 처리 목적이 달성된 후에는 지체 없이 파기됩니다.
- 계정 정보 (E-mail, 전화번호): 회원 탈퇴 시까지
- 위치 정보: 서비스 제공 종료 시까지
- 이용 기록: 서비스 이용 기록에 따른 보관 기간 동안
""")
                
                Text("3. 개인정보의 제3자 제공 여부")
                    .font(.headline)
                    .padding(.top, 5)
                Text("""
사용자의 개인정보는 원칙적으로 제3자에게 제공되지 않으며, 다음의 경우에만 예외적으로 제공될 수 있습니다:
- 법령에 따른 요청이 있는 경우
- 사용자가 명시적으로 동의한 경우
- 서비스 제공을 위해 필수적인 경우 (예: 위치 기반 서비스 제공을 위한 지도 API 제공업체)
""")
                
                Text("4. 개인정보의 파기 절차 및 방법")
                    .font(.headline)
                    .padding(.top, 5)
                Text("""
수집된 개인정보는 보유 기간이 경과하거나 처리 목적이 달성된 후, 안전한 방법으로 즉시 파기됩니다. 전자적 파일 형식으로 저장된 정보는 복구 불가능한 기술적 방법을 통해 삭제됩니다.
""")
                
                Text("5. 개인정보 보호를 위한 안전 조치")
                    .font(.headline)
                    .padding(.top, 5)
                Text("""
회사는 사용자의 개인정보를 보호하기 위해 다음과 같은 조치를 시행합니다:
- 개인정보의 암호화 저장 및 전송
- 접근 통제 및 권한 관리
- 개인정보 처리 담당자의 최소화 및 교육
""")
                
                Text("6. 개인정보 처리 방침의 변경")
                    .font(.headline)
                    .padding(.top, 5)
                Text("""
회사는 법령 변경 또는 서비스 운영 방침에 따라 개인정보 처리방침을 변경할 수 있으며, 변경 내용은 사전에 공지됩니다.
""")
            }
            .padding()
        }
        .navigationTitle("개인정보 처리방침")
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
