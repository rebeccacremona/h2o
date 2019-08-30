from rest_framework import serializers

from . import models


class ContentAnnotationSerializer(serializers.ModelSerializer):
    start_offset = serializers.IntegerField(source='global_start_offset')
    end_offset = serializers.IntegerField(source='global_end_offset')

    class Meta:
        model = models.ContentAnnotation
        fields = ('id', 'resource', 'start_offset', 'end_offset', 'kind', 'content', 'created_at', 'updated_at')


class CaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Case
        fields = ('id', 'content', 'name')


class TextBlockSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.TextBlock
        fields = ('id', 'content', 'name')


class ContentNodeSerializer(serializers.ModelSerializer):
    title = serializers.SerializerMethodField()
    resource = serializers.SerializerMethodField()
    annotations = ContentAnnotationSerializer(many=True)

    class Meta:
        model = models.ContentNode
        fields = ['id', 'title', 'subtitle', 'headnote', 'ordinals', 'ordinal_string', 'type', 'resource', 'resource_type', 'annotations']

    def get_title(self, node):
        return node.get_title()

    def get_resource(self, node):
        if node.type == 'resource':
            if node.resource_type == 'Case':
                return CaseSerializer(self.context['cases'].get(node.resource_id)).data
            elif node.resource_type == 'TextBlock':
                return TextBlockSerializer(self.context['textblocks'].get(node.resource_id)).data
            else:
                raise NotImplementedError
        else:
            return []


class CasebookSerializer(ContentNodeSerializer):
    contents = ContentNodeSerializer(many=True)

    class Meta(ContentNodeSerializer.Meta):
        model = models.Casebook
        fields = ContentNodeSerializer.Meta.fields + ['contents',]


class SectionSerializer(ContentNodeSerializer):
    contents = ContentNodeSerializer(many=True)

    class Meta(ContentNodeSerializer.Meta):
        model = models.Section
        fields = ContentNodeSerializer.Meta.fields + ['contents',]

