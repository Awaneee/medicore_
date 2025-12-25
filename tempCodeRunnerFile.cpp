#include <iostream>
#include <algorithm>
using namespace std;

typedef long long ll;

ll min_candles_needed(int N, int pos, ll bob_candles) {
    // Place bob_candles at position pos (1-indexed). Compute total needed.
    ll total = bob_candles;
    // Left side
    ll curr = bob_candles;
    for (int i = pos - 1; i >= 1; --i) {
        curr = max(curr - 1, 1LL);
        total += curr;
    }
    // Right side
    curr = bob_candles;
    for (int i = pos + 1; i <= N; ++i) {
        curr = max(curr - 1, 1LL);
        total += curr;
    }
    return total;
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    int T;
    cin >> T;
    while (T--) {
        int N, M, K;
        cin >> N >> M >> K;
        // Binary search for the answer
        ll lo = 1, hi = M, ans = 1;
        while (lo <= hi) {
            ll mid = (lo + hi) / 2;
            ll needed = min_candles_needed(N, K, mid);
            if (needed <= M) {
                ans = mid;
                lo = mid + 1;
            } else {
                hi = mid - 1;
            }
        }
        cout << ans << '\n';
    }
    return 0;
}
