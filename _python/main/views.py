from django.contrib.auth.decorators import login_required
from django.contrib.auth.views import redirect_to_login
from django.db.models import Prefetch
from django.http import HttpResponseForbidden, HttpResponseRedirect
from django.shortcuts import render, get_object_or_404
from django.views.generic import TemplateView
from rest_framework.decorators import api_view
from rest_framework.response import Response
import json

from .serializers import ContentAnnotationSerializer, CaseSerializer, TextBlockSerializer, CasebookSerializer, SectionSerializer
from .models import Casebook, Resource, Section, Case, TextBlock, User, ContentNode, ContentAnnotation


class DirectTemplateView(TemplateView):
    extra_context = None

    def get_context_data(self, **kwargs):
        """ Override Django's TemplateView to allow passing in extra_context. """
        context = super(self.__class__, self).get_context_data(**kwargs)
        if self.extra_context is not None:
            for key, value in self.extra_context.items():
                if callable(value):
                    context[key] = value()
                else:
                    context[key] = value
        return context


def login_required_response(request):
    if request.user.is_authenticated:
        return HttpResponseForbidden()
    else:
        return redirect_to_login(request.build_absolute_uri())


@api_view(['GET'])
def annotations(request, resource_id, format=None):
    """
        /resources/:resource_id/annotations view.
        Was: app/controllers/content/annotations_controller.rb
    """
    resource = get_object_or_404(Resource.objects.select_related('casebook'), pk=resource_id)

    # check permissions
    if not resource.casebook.viewable_by(request.user):
        return login_required_response(request)

    if request.method == 'GET':
        return Response(ContentAnnotationSerializer(resource.annotations.all(), many=True).data)


def index(request):
    if request.user.is_authenticated:
        return render(request, 'dashboard.html', {'user': request.user})
    else:
        return render(request, 'index.html')


def dashboard(request, user_id):
    user = get_object_or_404(User, pk=user_id)
    return render(request, 'dashboard.html', {'user': user})


def casebook(request, casebook_param):
    casebook = get_object_or_404(Casebook, id=casebook_param['id'])

    # check permissions
    if not casebook.viewable_by(request.user):
        return login_required_response(request)

    # canonical redirect
    canonical = casebook.get_absolute_url()
    if request.path != canonical:
        return HttpResponseRedirect(canonical)

    return render(request, 'casebook.html', {
        'casebook': casebook,
        'contents': casebook.contents.all().order_by('ordinals')
    })


def section(request, casebook_param, ordinals_param):
    section = get_object_or_404(Section.objects.select_related('casebook'), casebook=casebook_param['id'], ordinals=ordinals_param['ordinals'])

    # check permissions
    if not section.casebook.viewable_by(request.user):
        return login_required_response(request)

    # canonical redirect
    canonical = section.get_absolute_url()
    if request.path != canonical:
        return HttpResponseRedirect(canonical)

    return render(request, 'section.html', {
        'section': section
    })


def resource(request, casebook_param, ordinals_param):
    resource = get_object_or_404(Resource.objects.select_related('casebook'), casebook=casebook_param['id'], ordinals=ordinals_param['ordinals'])

    # check permissions
    if not resource.casebook.viewable_by(request.user):
        return login_required_response(request)

    # canonical redirect
    canonical = resource.get_absolute_url()
    if request.path != canonical:
        return HttpResponseRedirect(canonical)

    if resource.resource_type == 'Case':
        resource.json = json.dumps(CaseSerializer(resource.resource).data)
    elif resource.resource_type == 'TextBlock':
        resource.json = json.dumps(TextBlockSerializer(resource.resource).data)

    return render(request, 'resource.html', {
        'resource': resource,
        'include_vuejs': resource.resource_type in ['Case', 'TextBlock']
    })


def case(request, case_id):
    case = get_object_or_404(Case, id=case_id)
    if not case.public:
        return HttpResponseForbidden()

    case.json = json.dumps(CaseSerializer(case).data)
    return render(request, 'case.html', {
        'case': case,
        'include_vuejs': True
    })


@api_view(['GET'])
def export_casebook(request, casebook_param, format=None):
    # for experimentation.
    # access via /casebooks/79342/export/?format=json and similar

    # Get the casebook, plus its related content nodes and annotations
    contents = Prefetch('contents', queryset=ContentNode.objects.order_by('ordinals'))
    casebook = get_object_or_404(Casebook.objects.prefetch_related(contents).prefetch_related('contents__annotations'), id=casebook_param['id'])

    if not casebook.viewable_by(request.user):
        return login_required_response(request)

    # A hack to gather associated the links, cases, and textblocks as well,
    # since we don't have a polymorphic "resource" relationship defined for Django yet.
    # TODO: Defaults/Links
    cases = { c.id: c for c in Case.objects.filter(id__in=casebook.contents.filter(resource_type='Case').values_list('resource_id', flat=True)) }
    textblocks = {t.id: t for t in TextBlock.objects.filter(id__in=casebook.contents.filter(resource_type='Case').values_list('resource_id', flat=True)) }

    if request.method == 'GET':
        return render(request, 'export.html', {
            'casebook' : json.dumps(CasebookSerializer(
                casebook,
                context={
                    'cases': cases,
                    'textblocks': textblocks
                }
            ).data)
        })
