<template>
<div class="table-of-contents">
    <TableOfContentsEntry
        :item="item"
        :idx="1 + idx"
        v-for="(item, idx) in contents"
        :key="item.id">
    </TableOfContentsEntry>
</div>
</template>

<script>
import TableOfContentsEntry from "./TableOfContentsEntry";
export default {
    props: ['contents'],
    components: {
      TableOfContentsEntry
    }
}
</script>
