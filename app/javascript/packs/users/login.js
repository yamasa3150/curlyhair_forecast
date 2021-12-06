document.addEventListener('DOMContentLoaded', () => {
  const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  // LIFF SDKの他のメソッドを実行できるようになるための作業
  liff.init({
    liffId: "1656563626-39BbzVbP"
  })
    .then(() => {
      if (!liff.isLoggedIn()) {
        liff.login();
      }
    })
    // idTokenからユーザーIDを取得し、userテーブルに保存するための処理
    .then(() => {
      const idToken = liff.getIDToken();
      const body = `idToken=${idToken}`
      const request = new Request('/users', {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
          'X-CSRF-Token': token
        },
        method: 'POST',
        body: body
      });

      fetch(request)
        .then(() => {
          const redirect_url = `/`
          window.location = redirect_url
        })
    })
})
