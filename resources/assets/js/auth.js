(function() {
    console.log('authorize.js');

    const aplikasi = {
        compilerOptions: {
            delimiters: ["[[", "]]"]
        },
        data() {
            return {
                login: '',
                password: '',
                loginSuccess: 0,
                hasError: false,
                errorMessage: '',
                loginEndpoint: '',
                UI: {
                    successImage: '<svg height="117px" version="1.1" viewBox="0 0 117 117" width="117px" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><title/><desc/><defs/><g fill="none" fill-rule="evenodd" id="Page-1" stroke="none" stroke-width="1"><g fill-rule="nonzero" id="correct"><path d="M34.5,55.1 C32.9,53.5 30.3,53.5 28.7,55.1 C27.1,56.7 27.1,59.3 28.7,60.9 L47.6,79.8 C48.4,80.6 49.4,81 50.5,81 C50.6,81 50.6,81 50.7,81 C51.8,80.9 52.9,80.4 53.7,79.5 L101,22.8 C102.4,21.1 102.2,18.5 100.5,17 C98.8,15.6 96.2,15.8 94.7,17.5 L50.2,70.8 L34.5,55.1 Z" fill="#17AB13" id="Shape"/><path d="M89.1,9.3 C66.1,-5.1 36.6,-1.7 17.4,17.5 C-5.2,40.1 -5.2,77 17.4,99.6 C28.7,110.9 43.6,116.6 58.4,116.6 C73.2,116.6 88.1,110.9 99.4,99.6 C118.7,80.3 122,50.7 107.5,27.7 C106.3,25.8 103.8,25.2 101.9,26.4 C100,27.6 99.4,30.1 100.6,32 C113.1,51.8 110.2,77.2 93.6,93.8 C74.2,113.2 42.5,113.2 23.1,93.8 C3.7,74.4 3.7,42.7 23.1,23.3 C39.7,6.8 65,3.9 84.8,16.2 C86.7,17.4 89.2,16.8 90.4,14.9 C91.6,13 91,10.5 89.1,9.3 Z" fill="#4A4A4A" id="Shape"/></g></g></svg>',
                },
                validation: {
                    login: {
                        status: 0,
                        message: '',
                    },
                    password: {
                        status: 0,
                        message: '',
                    }
                }
            }
        },
        methods: {
            resetForm: function(){
                this.validation = {
                    login: {
                        status: 0,
                        message: '',
                    },
                    password: {
                        status: 0,
                        message: '',
                    }
                };
            },
            doLogin: function() {
                console.log('Authorize client');
                var buttonLogin = document.getElementById('btn-login');
                buttonLogin.innerHTML = 'Loading';
                if (this.login.trim().length == 0 || this.password.trim().length == 0) {
                    Toastify({
                        text: "Login failed",
                        className: "alert",
                        style: {
                            background: "red",
                        }
                    }).showToast();
                    return;
                }

                var fields = {
                    'login': this.login,
                    'password': this.password,
                };

                var _this = this;

                console.log(fields);
                // let url = this.loginEndpoint + 'login';
                let url = '/api/login'; 
                console.log(url);

                fetch(url, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(fields),
                    })
                    .then(res => res.json())
                    .then(res => {
                        buttonLogin.innerHTML = 'Masuk';

                        if (res.code == 200) {
                            if ('api_url' in res.data) {
                                window.localStorage.setItem("_base_api_url", res.data.api_url);
                                window.localStorage.setItem("_base_api_key", res.data.api_key);
                            }

                            _this.loginSuccess = 2;
                            Toastify({
                                text: "Login success",
                                className: "alert",
                                style: {
                                    background: "green",
                                }
                            }).showToast();
                            window.location.reload();
                            return;
                        } else {
                            console.log(res.errors);
                            _this.loginSuccess = 1;

                            if ("login" in res.errors) {
                                console.log(_this.validation);
                                console.log(res.errors.login.join("."));
                                _this.validation.login.status = 1;
                                _this.validation.login.message = res.errors.login.join(".");
                            }
                            
                            if ("password" in res.errors) {
                                console.log(_this.validation);
                                console.log(res.errors.password.join("."));
                                _this.validation.password.status = 1;
                                _this.validation.password.message = res.errors.password.join(".");
                            }

                           
                        }
                    });

            }
        },
        computed: {
            formValidated: function() {
                if (this.login.trim().length > 0 && this.password.trim().length > 0) {
                    return true;
                }
                return false;
            }
        },
        mounted() {
            this.loginEndpoint = _s('#api-endpoint').value;
        }
    }

    const app = Vue.createApp(aplikasi);
    app.mount('#app');
})();