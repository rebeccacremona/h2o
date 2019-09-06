import Vue from "vue";
Vue.config.productionTip = process.env.NODE_ENV == "development";

import store from "../store/index";
import Axios from "../config/axios";

import Casebook from "../components/export/Casebook";


document.addEventListener("DOMContentLoaded", () => {

  Axios.get('http://localhost:8001/casebooks/72837-an-introduction-to-the-law-of-corporations-cases-and-materials/export/?format=json')
    .then(response => {

      const casebook = response.data;

      const app = new Vue({
        el: "#app",
        store,
        components: {
          Casebook
        },
        // data () {
        //   return {
        //     casebook: {},
        //   }
        // },
        // mounted () {
        //   Axios.get('http://localhost:8001/casebooks/72837-an-introduction-to-the-law-of-corporations-cases-and-materials/export/?format=json')
        //     .then(response => {
        //       this.casebook = response.data ;
        //     });
        // }
        template: `<casebook :casebook="$root.casebook"></casebook>`,
        created () {
          this.casebook = Object.freeze(casebook)
        }
      });
      window.app = app;
    });

});


