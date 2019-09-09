<template functional>
<div v-if="props.node.type == 'section'">
  <div data-custom-style='Section Number' :data-toc-idx="props.idx">{{ props.node.ordinal_string }}</div>
  <div data-custom-style='Section Title'>{{ props.node.title }}</div>
  <div v-if="props.node.subtitle" data-custom-style='Section Subtitle'>{{ props.node.subtitle }}</div>
  <div v-if="props.node.headnote" data-custom-style='Section Headnote' v-html="props.node.headnote"></div>
</div>
<div v-else-if="props.node.type == 'resource'">
  <div data-custom-style='Resource Number' :data-toc-idx="props.idx">{{ props.node.ordinal_string }}</div>
  <div data-custom-style='Resource Title'>{{ props.node.title }}</div>
  <div v-if="props.node.subtitle" data-custom-style='Resource Subtitle'>{{ props.node.subtitle }}</div>
  <div v-if="props.node.headnote" data-custom-style='Resource Headnote' v-html="props.node.headnote"></div>
  <p v-if="['Case', 'TextBlock'].includes(props.node.resource_type)" class="todo">
    <the-resource-body :editable="false" :resource="props.node.resource" :annotations="props.node.annotations"></the-resource-body>
  </p>
  <div v-else-if="props.node.resource_type == 'Default'" data-custom-style='Resource Link'>
    <a href="props.node.resource.url" target="_blank">node.resource.url</a>
  </div>
</div>
</template>

<script>
import Vue from "vue"
import TheResourceBody from "../TheResourceBody";
Vue.component("the-resource-body", TheResourceBody);

export default {
  props: ['node', 'idx'],
}
</script>
