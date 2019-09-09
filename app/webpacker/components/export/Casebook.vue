<template functional>
<div class="casebook-wrapper">

  <div data-custom-style='Casebook Title'>{{ props.casebook.title }}</div>
  <div v-if="props.casebook.subtitle" data-custom-style='Casebook Subtitle'>{{ props.casebook.subtitle }}</div>
  <div v-if="props.casebook.headnote" data-custom-style='Casebook Headnote' v-html="props.casebook.headnote"></div>

  <table-of-contents :contents="props.casebook.contents"></table-of-contents>

  <content-node :node="node" :idx="1 + idx" v-for="(node, idx) in props.casebook.contents" :key="node.id"></content-node>

</div>
</template>

<script>
import Vue from "vue"
import TableOfContents from "./TableOfContents";
import ContentNode from "./ContentNode";
Vue.component("table-of-contents", TableOfContents);
Vue.component("content-node", ContentNode);

export default {
  props: ['casebook'],
}
</script>
