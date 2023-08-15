import React from 'react';
import Layout from '@theme/Layout';
import Translate, { translate } from '@docusaurus/Translate';
import './Resume.css';
import Head from '@site/src/components/Greeting/Head';

const Zoom = require('react-medium-image-zoom').default;
import 'react-medium-image-zoom/dist/styles.css'

const TITLE = translate({ message: 'Resume' });
const DESCRIPTION = translate({ message: 'Resume' });

export default function Resume() {
  return (
    <Layout title={TITLE} description={DESCRIPTION}>
      <div>
        <section className="greeting-flex">
          <Head />
          {/* text & button */}
          {/* <a href="/宋锦丰_DevOps-运维开发-容器运维_18660386849.pdf" rel="noopener noreferrer" target="_blank" className="greeting-resume-button"><Translate>Download Resume</Translate></a> */}
        </section>
        {/* Cert */}
        <section className="grid md:grid-cols-3 gap-4 my-8 max-w-5xl mx-auto">

          <div className="relative shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/CKS.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer" href="https://www.credly.com/badges/02d42601-dfd8-41de-a90b-6e1aba0c716d"><Translate>Certified Kubernetes Security Specialist (CKS)</Translate></a>
            </div>
          </div>

          <div className="relative row-span-2 col-span-2 shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/CKA.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer" href="https://www.credly.com/badges/7f665fcf-c0a4-44e7-8b09-06584280dfc2"><Translate>Certified Kubernetes Administrator (CKA)</Translate></a>
            </div>
          </div>

          <div className="relative shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/CKAD.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer" href="https://www.credly.com/badges/c37a3b97-5438-4c05-a28b-6ea2d6f38905"><Translate>Certified Kubernetes Application Developer (CKAD)</Translate></a>
            </div>
          </div>
          <div className="relative row-span-2 col-span-2 shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/RHCE.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer" href="https://www.credly.com/badges/14b87040-30ed-446d-b269-b693a2f0a0d0"> <Translate>Red Hat Certified Engineer (RHCE)</Translate></a>
            </div>
          </div>
          <div className="relative shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/RHCSA.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer" href="https://www.credly.com/badges/46d4a035-24e7-4408-9237-42eba03c64cf"><Translate>Red Hat Certified System Administrator (RHCSA)</Translate></a>
            </div>
          </div>
          <div className="relative  shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/ACA-DEVOPS.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer"><Translate>Alibaba Cloud Certified Associate - DevOps (ACA)</Translate></a>
            </div>
          </div>
          <div className="relative  shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/H3CNE-Net.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer"><Translate>H3C Certified Network Engineer (H3CNE)</Translate></a>
            </div>
          </div>


          <div className="relative row-span-2 col-span-2 shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/ACP.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer"><Translate>Alibaba Cloud Certified Professional - Cloud Computing (ACP)</Translate></a>
            </div>
          </div>
          <div className="relative shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/H3CNE-Cloud.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer"><Translate>H3C Certified Network Engineer for Cloud (H3CNE-Cloud)</Translate></a>
            </div>
          </div>
          <div className="relative shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/2018年山东省职业院校技能大赛 云计算技术与应用赛项 二等奖.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer"><Translate>2018 Shandong Province Vocational College Cloud Computing Technology and Applications Competition Second Prize</Translate></a>
            </div>
          </div>

          <div className="relative shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/云计算大数据讲师认证证书.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer"><Translate>Cloud computing big data lecturer certification (CETC)</Translate></a>
            </div>
          </div>

          <div className="relative  shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/2018年山东省职业院校 云计算大数据行业技能大赛 一等奖.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer"><Translate>2018 Shandong vocational colleges cloud computing big data industry skills competition first prize</Translate></a>
            </div>
          </div>

          <div className="relative  shadow-sm md:shadow-2xl">
            <Zoom><img className="rounded object-cover w-full h-full" loading="lazy" src="/img/cert/ArgoCD-AKUITY.webp" /></Zoom>
            <div className="noclick bg-black absolute top-0 left-0 rounded w-full h-full  bg-opacity-30 grid place-items-center opacity-0 hover:opacity-100 transition-opacity duration-200">
              <a className="bg-black Dbutton px-6 py-2 rounded-full  text-white resume-hide" target="_blank" rel="noopener noreferrer" href="https://www.credential.net/d8d99fb8-92b1-4fee-8e71-cd6158277c19#gs.46sctu"><Translate>Introduction to Continuous Delivery and GitOps using Argo CD</Translate></a>
            </div>
          </div>
       
        </section>

        {/* <section className="my-4 max-w-5xl mx-auto">
        <div className="text-3xl font-bold mb-8"><Translate>Resume</Translate></div>
        <div className="grid grid-cols-2 gap-4">
          工作经历
          <div>
            <div className="text-2xl font-semibold mb-4"><Translate>Working Experience</Translate></div>
            经历1
            <div>
              <div className="text-xl font-bold my-2"><Translate>Google</Translate></div>
              <p className="my-1 font-light"><Translate>Product Engineer</Translate></p>
              <p className="text-gray-500 my-1"><Translate>Nov 2019 - Apr 2021</Translate></p>
            </div>
            经历2
            <div>
              <div className="text-xl font-bold my-2"><Translate>Amazon</Translate></div>
              <p className="my-1 font-light"><Translate>Sr. UX Designer</Translate></p>
              <p className="text-gray-500 my-1"><Translate>Jan 2016 - Oct 2019</Translate></p>
            </div>
          </div>
          技能
          <div>
            <div className="text-2xl font-semibold mb-4"><Translate>Skills</Translate></div>
            <div className="text-xl font-light my-2"><Translate>Visual Design</Translate></div>
            <div className="text-xl font-light my-2"><Translate>Product Development</Translate></div>
          </div>
          其他经历
          <div>
            <div className="text-2xl font-semibold mb-4">Courses</div>
            <div>
              <div className="text-xl font-bold my-2">Design Principles</div>
              <p className="my-1 font-light">by UX Academy</p>
              <p className="text-gray-500 my-1">Nov 2019 - Jan 2020</p>
            </div>
          </div>
        </div>
      </section> */}

        <section className="my-16 max-w-2xl mx-auto">
          <div className="text-4xl font-bold text-center">
            <a className="Dbutton text-5xl text-blue-400 hover:text-blue-400" href="mailto:song.jinfeng@outlook.com"><Translate>Let's Chat</Translate>📨</a>
          </div>
        </section>

      </div>

    </Layout>
  );
}