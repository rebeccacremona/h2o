<template functional>
<div class="table-of-contents">
    <table-of-contents-entry
        :item="item"
        :idx="1 + idx"
        v-for="(item, idx) in props.contents"
        :key="item.id">
    </table-of-contents-entry>
</div>
</template>

<script>
import Vue from "vue"
import TableOfContentsEntry from "./TableOfContentsEntry";
Vue.component("table-of-contents-entry", TableOfContentsEntry);

export default {
    props: ['contents'],
}
</script>
