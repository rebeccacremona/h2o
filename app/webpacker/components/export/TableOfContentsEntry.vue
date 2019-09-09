<template functional>
<div class="toc-entry"
    :data-depth="props.item.ordinals.length"
    :data-idx="props.idx"
    :data-title="props.item.ordinal_string + ' ' + props.item.title">
</div>
</template>

<script>
export default {
    props: ['item', 'idx'],
}
</script>
