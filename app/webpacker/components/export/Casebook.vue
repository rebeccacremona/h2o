<template>
<div class="casebook-wrapper">

  <div data-custom-style='Casebook Title'>{{ casebook.title }}</div>
  <div v-if="casebook.subtitle" data-custom-style='Casebook Subtitle'>{{ casebook.subtitle }}</div>
  <div v-if="casebook.headnote" data-custom-style='Casebook Headnote' v-html="casebook.headnote"></div>

  <TableOfContents :contents="casebook.contents"></TableOfContents>

  <ContentNode :node="node" :idx="1 + idx" v-for="(node, idx) in casebook.contents" :key="node.id"></ContentNode>

</div>
</template>

<script>
import TableOfContents from "./TableOfContents";
import ContentNode from "./ContentNode";

export default {
  props: ['casebook'],
  components: {
    TableOfContents,
    ContentNode
  }
}
</script>
