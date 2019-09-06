<template>
<div class="toc-entry"
    :data-depth="item.ordinals.length"
    :data-idx="idx"
    :data-title="item.ordinal_string + ' ' + item.title">
</div>
</template>

<script>
export default {
    props: ['item', 'idx'],
}
</script>
