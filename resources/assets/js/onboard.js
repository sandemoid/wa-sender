(function() {
    console.log('onboard-v001.js');

    const aplikasi = {
        compilerOptions: {
            delimiters: ["${", "}"]
        },
        data() {
            return {
                version: '1.0.0',
                appName: 'OneSender',
                apiUrl: '',
                installStep: 1,
                step1: {
                    authorizationUrl: '',
                    mode: 'button', // serial
                    serialNumber: '',
                },
                password: '',
                hasError: false,
                errorMessage: '',
                loginEndpoint: '',
            }
        },
        methods: {
            changeStep1Mode: function() {
                this.step1.mode = this.step1.mode == 'button' ? 'serial' : 'button';
            },
            goToAuthorization: function() {
                window.location.href = this.step1.authorizationUrl;
            },
            activateWithSerial: function() {
                console.log('Authorize client');
                // https://p14.dev/access/
                // 
                // var params = {
                //     'action': 'activate-onesender-app',
                //     'data': {
                //         'serial': 'aaa-bbb-ccc'
                //         'device_signature': 'login',
                //         'app_signature': 'password',
                //     }
                // };

                var params = {
                    serial: this.step1.serialNumber,
                };

                var _this = this;

                console.log(params);
                let url = this.apiUrl + 'onboard/validate-serial';

                console.log(url);
                fetch(url, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(params),
                    })
                    .then(res => res.json())
                    .then(res => {
                        console.log(res);
                        // jika valid
                        // - tampilan valid
                        // - go to next page

                        // invalid
                        // - show message
                    });

            },

        },
        computed: {
            formValidated: function() {
                return true;
            },
            isStep1: function() {
                return this.installStep == 1;
            },
            isStep2: function() {
                return this.installStep == 2;
            },
            isStep3: function() {
                return this.installStep == 3;
            }
        },
        mounted() {
            let apiUrl = _s('#api-url').value;
            let appName = _s('#app-name').value;
            let authorizationUrl = _s('#authorization-url').value;
            let appSignature = _s('#app-signature').value;
            appSignature = btoa(appSignature);
            let redirect = encodeURIComponent(window.location.href);

            let installStep = parseInt(_s('#install-step').value, 10);
            this.appName = appName;
            this.apiUrl = apiUrl;
            this.installStep = installStep;

            this.step1.authorizationUrl = `${authorizationUrl}?scope=onesender&redirect_uri=${redirect}&token=${appSignature}`;

            console.log(this.installStep);
        }
    };

    function componentOnboardSetting() {
        return {
            data() {
                return {
                    fields: {
                        login: '',
                        password: '',
                        server_port: '',
                        server_url: '',
                        server_websocket_url: '',
                    },
                    errorForm: {
                        login: '',
                        password: '',
                        server_port: '',
                        server_url: '',
                        server_websocket_url: '',
                    },
                    apiUrl: '',
                    serialHash: '',
                }
            },
            methods: {
                resetFormSetting: function() {
                    this.errorForm = {
                        login: '',
                        password: '',
                        server_port: '',
                        server_url: '',
                        server_websocket_url: '',
                    };
                },
                saveOnboardSetting: function() {
                    console.log('Save setting');

                    var fields = {
                        'serial_hash': this.serialHash,
                        'login': this.fields.login,
                        'password': this.fields.password,
                        'server_port': this.fields.server_port,
                        'server_url': this.fields.server_url,
                        'server_websocket_url': this.fields.server_websocket_url,
                    };

                    var hasError = false;
                    if (this.fields.login.trim().length < 1) {
                        this.errorForm.login = 'Kolom E-Mail wajib diisi.';
                        hasError = true;
                    }
                    
                    if (this.fields.password.trim().length < 1) {
                        this.errorForm.password = 'Kolom password wajib diisi.';
                        hasError = true;
                    }

                    if (this.fields.server_url.trim().length < 1) {
                        this.errorForm.server_url = 'Kolom URL wajib diisi.';
                        hasError = true;
                    }

                    if (this.fields.server_websocket_url.trim().length < 1) {
                        this.errorForm.server_websocket_url = 'Kolom websocket url wajib diisi.';
                        hasError = true;
                    }

                    if (hasError) {
                        console.log( this.errorForm);
                        return;
                    }

                    var _this = this;

                    console.log(fields);
                    let url = '/api/onboard/setting';
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
                            console.log(res);
                            if (res.code == 200) {
                                Toastify({
                                    text: res.message,
                                    className: "alert",
                                    style: {
                                        background: "green",
                                    }
                                }).showToast();
                                document.getElementById('install-step-2').className += ' d-none';
                                document.getElementById('install-step-3').className = document.getElementById('install-step-3').className.replace(' d-none', '');
                                window.location.reload();
                            } else {
                                Toastify({
                                    text: res.message,
                                    className: "alert",
                                    style: {
                                        background: "red",
                                    }
                                }).showToast();

                            }

                        });
                }
            },
            mounted: function() {
                let serialHash = _s('#serial-hash').value;
                let apiUrl = _s('#api-url').value;
                let setting_login = _s('#setting-login').value;
                let setting_port = _s('#setting-port').value;
                let setting_url = _s('#setting-url').value;
                let setting_api_url = _s('#setting-api-url').value;
                let setting_websocket_url = _s('#setting-websocket-url').value;

                this.apiUrl = apiUrl;
                this.serialHash = serialHash;

                this.fields.login = setting_login;
                this.fields.server_port = setting_port;
                this.fields.server_url = setting_url;
                this.fields.server_websocket_url = setting_websocket_url;

                console.log(this.fields);
            },
            template: `
                <div class="setting-blocks">
                    <div class="setting-group">
                        <header>Login</header>
                        <div class="body">
                            <div class="form-group" :class="{'is-invalid' : errorForm.login.length > 0}">
                                <label for="field_login">Email/login</label>
                                <div class="body">
                                    <input type="text" name="field_login" id="field_login" class="form-control" v-model="fields.login">
                                    <div class="error-wrap" id="error_field_login">{{errorForm.login}}</div>
                                </div>
                            </div><!-- form-group -->
                            <div class="form-group" :class="{'is-invalid' : errorForm.password.length > 0}">
                                <label for="field_password">Password</label>
                                <div class="body">
                                    <input type="password" name="field_password" id="field_password" class="form-control" v-model="fields.password">
                                    <div class="error-wrap" id="error_field_password">{{errorForm.password}}</div>
                                </div>
                            </div><!-- form-group -->
                        </div>
                    </div> <!-- .setting-group -->
             
                    <div class="setting-group">
                        <header>Server</header>
                        <div class="body">
                        <form @keypress="resetFormSetting">
                            <div class="form-group">
                                <label for="field_port">Server port</label>
                                <div class="body">
                                    <input type="number" name="field_port" id="field_port" class="form-control" v-model="fields.server_port">
                                    <div class="desc">
                                        Example: 3000
                                    </div>
                                    <div class="error-wrap" id="error_field_port"></div>
                                </div>
                            </div><!-- form-group -->

                            <div class="form-group" :class="{'is-invalid' : errorForm.server_url.length > 0}">
                                <label for="field_base_url">Base website url</label>
                                <div class="body">
                                    <input type="text" name="field_base_url" id="field_base_url" class="form-control" v-model="fields.server_url">
                                    <div class="desc">
                                        Example: http://localhost:3000, http://10.0.0.1:3001
                                    </div>
                                    <div class="error-wrap" id="error_field_server_url">{{errorForm.server_url}}</div>
                                </div>
                            </div><!-- form-group -->

                            <div class="form-group" :class="{'is-invalid' : errorForm.server_websocket_url.length > 0}">
                                <label for="field_websocket_url">Websocket url</label>
                                <div class="body">
                                    <input type="text" name="field_websocket_url" id="field_websocket_url" class="form-control" v-model="fields.server_websocket_url">
                                    <div class="desc">
                                        Example: ws://localhost:3000/ws/
                                    </div>
                                    <div class="error-wrap" id="error_field_websocket_url">{{errorForm.websocket_url}}</div>
                                </div>
                            </div><!-- form-group -->
                        </form>
                        </div>
                    </div> <!-- .setting-group -->

                    <div class="action-bar">
                        <button class="btn btn-primary" v-on:click.prevent="saveOnboardSetting">Save and restart server</button>
                    </div>
                </div>`
        };
    }

    const app = Vue.createApp(aplikasi);
    app.component('onboard-setting', componentOnboardSetting());
    app.mount('#app');
})();