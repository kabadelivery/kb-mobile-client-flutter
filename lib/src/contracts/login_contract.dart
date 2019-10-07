


/* login contract */
class LoginContract {

  void login (String password, String phoneCode){}
}

class LoginView {
  void showLoading(bool isLoading) {}
  void loginSuccess () {}
  void loginFailure (String message) {}
}


/* login presenter */
class LoginPresenter implements LoginContract {

  @override
  void login(String password, String phoneCode) {

    /* make network request, create a lib that makes network request. */


  }

}