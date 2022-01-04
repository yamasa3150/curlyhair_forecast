document.addEventListener('DOMContentLoaded', () => {

  const setting_form = document.querySelector('#setting_form')
  setting_form.addEventListener('ajax:success', (e) => {
    swal(`設定を保存しました`);
  })
  setting_form.addEventListener('ajax:error', (e) => {
    swal(`地域もしくは時刻が設定されてません`);
  })

})
