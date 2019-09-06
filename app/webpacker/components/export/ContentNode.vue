<template>
<div v-if="node.type == 'section'">
  <div data-custom-style='Section Number' :data-toc-idx="idx">{{ node.ordinal_string }}</div>
  <div data-custom-style='Section Title'>{{ node.title }}</div>
  <div v-if="node.subtitle" data-custom-style='Section Subtitle'>{{ node.subtitle }}</div>
  <div v-if="node.headnote" data-custom-style='Section Headnote' v-html="node.headnote"></div>
</div>
<div v-else-if="node.type == 'resource'">
  <div data-custom-style='Resource Number' :data-toc-idx="idx">{{ node.ordinal_string }}</div>
  <div data-custom-style='Resource Title'>{{ node.title }}</div>
  <div v-if="node.subtitle" data-custom-style='Resource Subtitle'>{{ node.subtitle }}</div>
  <div v-if="node.headnote" data-custom-style='Resource Headnote' v-html="node.headnote"></div>
  <p v-if="['Case', 'TextBlock'].includes(node.resource_type)" class="todo">
    <TheResourceBody :editable="false" :resource="node.resource" :annotations="node.annotations"></TheResourceBody>
  </p>
  <div v-else-if="node.resource_type == 'Default'" data-custom-style='Resource Link'>
    <a href="node.resource.url" target="_blank">node.resource.url</a>
  </div>
</div>
</template>

<script>
import TheResourceBody from "../TheResourceBody";
export default {
  props: ['node', 'idx'],
  components: {
    TheResourceBody,
  }
}
</script>
